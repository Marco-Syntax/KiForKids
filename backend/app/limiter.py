"""
Limiter-Instanz für die gesamte App, um zirkuläre Importe zu vermeiden.
"""
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)
