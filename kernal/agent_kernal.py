# Copyright (c) 2024 Thure Merlin Foken
# Alle Rechte vorbehalten.

import os
import sys
import time
import json
import multiprocessing
import threading
import importlib.util
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from globals.KernalBasics import *


logger = get_logger("agent_kernal")

STATE_FILE = './pipes/modules_state.json'


# --- Custom Stream to Redirect Process Output ---
class StreamToQueue:
    def __init__(self, queue, module_name):
        self.queue = queue
        self.module_name = module_name

    def write(self, message):
        if message.strip():
            self.queue.put(f'[{self.module_name:<12}] {message.strip()}')

    def flush(self):
        pass


# --- Worker Function for Each Module Process ---
def run_module_worker(module_path, module_name, output_queue):
    try:
        spec = importlib.util.spec_from_file_location(module_name, module_path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        if not hasattr(mod, 'run'):
            output_queue.put(f'Module {module_name} does not have a run() function.')
            return
        # Redirect stdout and stderr
        original_stdout = sys.stdout
        original_stderr = sys.stderr
        sys.stdout = StreamToQueue(output_queue, module_name)
        sys.stderr = StreamToQueue(output_queue, module_name)
        mod.run()
    except Exception as e:
        output_queue.put(f'Error in module {module_name}: {e}')
    finally:
        sys.stdout = original_stdout
        sys.stderr = original_stderr


# --- Module Manager Class ---
class ModuleManager:
    def __init__(self, modules_folder, output_queue):
        self.modules_folder = modules_folder
        self.output_queue = output_queue
        # active_modules maps module_name -> dict with keys: process, file_path, last_mod
        self.active_modules = {}
        # desired_states maps module_name -> 'running' or 'stopped'
        self.desired_states = self.load_state()

    def load_state(self):
        if os.path.exists(STATE_FILE):
            try:
                with open(STATE_FILE, 'r') as f:
                    state = json.load(f)
                logger.info('Loaded module state from JSON.')
                return state
            except Exception as e:
                logger.error(f'Failed to load state file: {e}')
        return {}

    def save_state(self):
        try:
            with open(STATE_FILE, 'w') as f:
                json.dump(self.desired_states, f, indent=2)
            logger.info('Module state saved.')
        except Exception as e:
            logger.error(f'Failed to save state file: {e}')

    def start_module(self, module_name, file_path):
        # Update desired state to running
        self.desired_states[module_name] = 'running'
        self.save_state()
        if module_name in self.active_modules:
            logger.info(f'Module {module_name} is already running.')
            return
        logger.info(f'Starting module {module_name}.')
        process = multiprocessing.Process(
            target=run_module_worker,
            args=(file_path, module_name, self.output_queue),
            name=module_name
        )
        process.start()
        mod_time = os.path.getmtime(file_path)
        self.active_modules[module_name] = {'process': process,
                                            'file_path': file_path,
                                            'last_mod': mod_time}

    def stop_module(self, module_name):
        # Update desired state to stopped
        if module_name not in set(list(self.desired_states.keys()) + list(self.active_modules.keys())):
            logger.info(f'Module {module_name} does not exist.')
            return
        self.desired_states[module_name] = 'stopped'
        self.save_state()
        if module_name not in self.active_modules:
            logger.info(f'Module {module_name} is not running.')
            return
        logger.info(f'Stopping module {module_name}.')
        process = self.active_modules[module_name]['process']
        if process.is_alive():
            process.terminate()
            process.join()
        del self.active_modules[module_name]

    def restart_module(self, module_name):
        file_path = os.path.join(self.modules_folder, module_name + '.py')
        # Only restart if desired state is running
        if self.desired_states.get(module_name, 'running') != 'running':
            logger.info(f'Module {module_name} is set to stopped. Not restarting.')
            return
        logger.info(f'Restarting module {module_name}.')
        self.stop_module(module_name)
        time.sleep(0.5)  # Allow OS to cleanup
        if os.path.exists(file_path):
            self.start_module(module_name, file_path)
        else:
            logger.info(f'Module file for {module_name} no longer exists.')

    def update_modules(self):
        # Scan the modules folder for Python files
        current_files = {}
        for filename in os.listdir(self.modules_folder):
            if filename.endswith('.py') and not filename.startswith('_'):
                module_name = filename[:-3]
                file_path = os.path.join(self.modules_folder, filename)
                current_files[module_name] = file_path
                mod_time = os.path.getmtime(file_path)
                # Only auto-start or restart if desired state is running.
                desired = self.desired_states.get(module_name, 'running')
                if module_name in self.active_modules:
                    if mod_time > self.active_modules[module_name]['last_mod']:
                        logger.info(f'Module {module_name} file changed.')
                        if desired == 'running':
                            self.restart_module(module_name)
                        else:
                            logger.info(f'Module {module_name} is set to stopped; not restarting.')
                else:
                    if desired == 'running':
                        logger.info(f'New module {module_name} detected, starting.')
                        self.start_module(module_name, file_path)
                    # else:
                    #     logger.info(f'New module {module_name} detected but set to stopped.')
        # Stop modules that no longer exist
        for module_name in list(self.active_modules.keys()):
            if module_name not in current_files:
                logger.info(f'Module {module_name} removed from folder, stopping.')
                self.stop_module(module_name)
                # Remove from desired state as well
                if module_name in self.desired_states:
                    del self.desired_states[module_name]
                    self.save_state()


# --- Filesystem Event Handler ---
class ModuleEventHandler(FileSystemEventHandler):
    def __init__(self, module_manager):
        self.module_manager = module_manager

    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith('.py'):
            module_name = os.path.basename(event.src_path)[:-3]
            logger.info(f'Detected modification in module {module_name}.')
            # Only restart if desired state is running
            if self.module_manager.desired_states.get(module_name, 'running') == 'running':
                self.module_manager.restart_module(module_name)
            else:
                logger.info(f'Module {module_name} is set to stopped; not restarting.')

    def on_created(self, event):
        if not event.is_directory and event.src_path.endswith('.py'):
            module_name = os.path.basename(event.src_path)[:-3]
            logger.info(f'Detected creation of module {module_name}.')
            desired = self.module_manager.desired_states.get(module_name, 'running')
            if desired == 'running':
                self.module_manager.start_module(module_name, event.src_path)
            else:
                logger.info(f'Module {module_name} is set to stopped; not starting.')

    def on_deleted(self, event):
        if not event.is_directory and event.src_path.endswith('.py'):
            module_name = os.path.basename(event.src_path)[:-3]
            logger.info(f'Detected deletion of module {module_name}.')
            self.module_manager.stop_module(module_name)
            if module_name in self.module_manager.desired_states:
                del self.module_manager.desired_states[module_name]
                self.module_manager.save_state()


# --- Output Listener Thread ---
def output_listener(output_queue):
    while True:
        message = output_queue.get()
        if message is None:
            break
        logger.info(message)


# --- Main Execution ---
if __name__ == '__main__':
    modules_folder = 'modules'
    if not os.path.exists(modules_folder):
        os.makedirs(modules_folder)

    multiprocessing.set_start_method('spawn')
    output_queue = multiprocessing.Queue()
    module_manager = ModuleManager(modules_folder, output_queue)

    # Initially load or update modules based on desired state.
    module_manager.update_modules()

    threading.Thread(target=output_listener, args=(output_queue,), daemon=True).start()

    event_handler = ModuleEventHandler(module_manager)
    observer = Observer()
    observer.schedule(event_handler, modules_folder, recursive=False)
    observer.start()

    try:
        while True:
            time.sleep(1)
            module_manager.update_modules()
    except KeyboardInterrupt:
        logger.info('Shutting down observer and all modules...')
        observer.stop()
        # Iterate over a copy of the keys to avoid modification issues during iteration
        for module_name in list(module_manager.active_modules.keys()):
            logger.info(f'Terminating module {module_name}.')
            process = module_manager.active_modules[module_name]['process']
            if process.is_alive():
                process.terminate()
                process.join()
    observer.join()
