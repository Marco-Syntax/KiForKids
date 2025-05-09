// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResultsEntry {

 String get fach; String get topic; List<String> get questions; List<String> get userAnswers; List<String> get feedback; DateTime get timestamp;
/// Create a copy of ResultsEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResultsEntryCopyWith<ResultsEntry> get copyWith => _$ResultsEntryCopyWithImpl<ResultsEntry>(this as ResultsEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResultsEntry&&(identical(other.fach, fach) || other.fach == fach)&&(identical(other.topic, topic) || other.topic == topic)&&const DeepCollectionEquality().equals(other.questions, questions)&&const DeepCollectionEquality().equals(other.userAnswers, userAnswers)&&const DeepCollectionEquality().equals(other.feedback, feedback)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,fach,topic,const DeepCollectionEquality().hash(questions),const DeepCollectionEquality().hash(userAnswers),const DeepCollectionEquality().hash(feedback),timestamp);

@override
String toString() {
  return 'ResultsEntry(fach: $fach, topic: $topic, questions: $questions, userAnswers: $userAnswers, feedback: $feedback, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $ResultsEntryCopyWith<$Res>  {
  factory $ResultsEntryCopyWith(ResultsEntry value, $Res Function(ResultsEntry) _then) = _$ResultsEntryCopyWithImpl;
@useResult
$Res call({
 String fach, String topic, List<String> questions, List<String> userAnswers, List<String> feedback, DateTime timestamp
});




}
/// @nodoc
class _$ResultsEntryCopyWithImpl<$Res>
    implements $ResultsEntryCopyWith<$Res> {
  _$ResultsEntryCopyWithImpl(this._self, this._then);

  final ResultsEntry _self;
  final $Res Function(ResultsEntry) _then;

/// Create a copy of ResultsEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? fach = null,Object? topic = null,Object? questions = null,Object? userAnswers = null,Object? feedback = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
fach: null == fach ? _self.fach : fach // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self.questions : questions // ignore: cast_nullable_to_non_nullable
as List<String>,userAnswers: null == userAnswers ? _self.userAnswers : userAnswers // ignore: cast_nullable_to_non_nullable
as List<String>,feedback: null == feedback ? _self.feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<String>,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// @nodoc


class _ResultsEntry implements ResultsEntry {
  const _ResultsEntry({required this.fach, required this.topic, required final  List<String> questions, required final  List<String> userAnswers, required final  List<String> feedback, required this.timestamp}): _questions = questions,_userAnswers = userAnswers,_feedback = feedback;
  

@override final  String fach;
@override final  String topic;
 final  List<String> _questions;
@override List<String> get questions {
  if (_questions is EqualUnmodifiableListView) return _questions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_questions);
}

 final  List<String> _userAnswers;
@override List<String> get userAnswers {
  if (_userAnswers is EqualUnmodifiableListView) return _userAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userAnswers);
}

 final  List<String> _feedback;
@override List<String> get feedback {
  if (_feedback is EqualUnmodifiableListView) return _feedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_feedback);
}

@override final  DateTime timestamp;

/// Create a copy of ResultsEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResultsEntryCopyWith<_ResultsEntry> get copyWith => __$ResultsEntryCopyWithImpl<_ResultsEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResultsEntry&&(identical(other.fach, fach) || other.fach == fach)&&(identical(other.topic, topic) || other.topic == topic)&&const DeepCollectionEquality().equals(other._questions, _questions)&&const DeepCollectionEquality().equals(other._userAnswers, _userAnswers)&&const DeepCollectionEquality().equals(other._feedback, _feedback)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,fach,topic,const DeepCollectionEquality().hash(_questions),const DeepCollectionEquality().hash(_userAnswers),const DeepCollectionEquality().hash(_feedback),timestamp);

@override
String toString() {
  return 'ResultsEntry(fach: $fach, topic: $topic, questions: $questions, userAnswers: $userAnswers, feedback: $feedback, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$ResultsEntryCopyWith<$Res> implements $ResultsEntryCopyWith<$Res> {
  factory _$ResultsEntryCopyWith(_ResultsEntry value, $Res Function(_ResultsEntry) _then) = __$ResultsEntryCopyWithImpl;
@override @useResult
$Res call({
 String fach, String topic, List<String> questions, List<String> userAnswers, List<String> feedback, DateTime timestamp
});




}
/// @nodoc
class __$ResultsEntryCopyWithImpl<$Res>
    implements _$ResultsEntryCopyWith<$Res> {
  __$ResultsEntryCopyWithImpl(this._self, this._then);

  final _ResultsEntry _self;
  final $Res Function(_ResultsEntry) _then;

/// Create a copy of ResultsEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? fach = null,Object? topic = null,Object? questions = null,Object? userAnswers = null,Object? feedback = null,Object? timestamp = null,}) {
  return _then(_ResultsEntry(
fach: null == fach ? _self.fach : fach // ignore: cast_nullable_to_non_nullable
as String,topic: null == topic ? _self.topic : topic // ignore: cast_nullable_to_non_nullable
as String,questions: null == questions ? _self._questions : questions // ignore: cast_nullable_to_non_nullable
as List<String>,userAnswers: null == userAnswers ? _self._userAnswers : userAnswers // ignore: cast_nullable_to_non_nullable
as List<String>,feedback: null == feedback ? _self._feedback : feedback // ignore: cast_nullable_to_non_nullable
as List<String>,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$HomeState {

 UserModel get user; String? get selectedTopic; bool get showTasks; List<Map<String, String>>? get generatedTasks; bool get isLoadingTasks; String? get taskError; List<String>? get lastFeedback;// Feedback der KI-Korrektur
 bool get isCheckingAnswers;// Status für Antwortprüfung
 String? get activeSubject;// aktuell aktives Fach
 Map<String, List<ResultsEntry>> get resultsHistory;// Ergebnisse pro Fach
 String get greeting;// Begrüßungstext
 String get testMode;// Testmodus
 bool get testLocked;// Sperrstatus für Testmodus-Buttons
// Wieder hinzugefügte Test-Felder
// Für alle Test-Typen gemeinsam
 List<String> get currentTestTasks; bool get showTestResult; List<bool> get testIsCorrect; List<String> get testFeedback; bool get isCheckingTest; bool get canContinueTest;// Spezifisch für Text-Eingabe Tests
 List<String> get textInputAnswers;// Spezifisch für True/False Tests
 List<String?> get trueFalseAnswers;// Spezifisch für MC Tests
 List<String?> get mcAnswers;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.user, user) || other.user == user)&&(identical(other.selectedTopic, selectedTopic) || other.selectedTopic == selectedTopic)&&(identical(other.showTasks, showTasks) || other.showTasks == showTasks)&&const DeepCollectionEquality().equals(other.generatedTasks, generatedTasks)&&(identical(other.isLoadingTasks, isLoadingTasks) || other.isLoadingTasks == isLoadingTasks)&&(identical(other.taskError, taskError) || other.taskError == taskError)&&const DeepCollectionEquality().equals(other.lastFeedback, lastFeedback)&&(identical(other.isCheckingAnswers, isCheckingAnswers) || other.isCheckingAnswers == isCheckingAnswers)&&(identical(other.activeSubject, activeSubject) || other.activeSubject == activeSubject)&&const DeepCollectionEquality().equals(other.resultsHistory, resultsHistory)&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.testMode, testMode) || other.testMode == testMode)&&(identical(other.testLocked, testLocked) || other.testLocked == testLocked)&&const DeepCollectionEquality().equals(other.currentTestTasks, currentTestTasks)&&(identical(other.showTestResult, showTestResult) || other.showTestResult == showTestResult)&&const DeepCollectionEquality().equals(other.testIsCorrect, testIsCorrect)&&const DeepCollectionEquality().equals(other.testFeedback, testFeedback)&&(identical(other.isCheckingTest, isCheckingTest) || other.isCheckingTest == isCheckingTest)&&(identical(other.canContinueTest, canContinueTest) || other.canContinueTest == canContinueTest)&&const DeepCollectionEquality().equals(other.textInputAnswers, textInputAnswers)&&const DeepCollectionEquality().equals(other.trueFalseAnswers, trueFalseAnswers)&&const DeepCollectionEquality().equals(other.mcAnswers, mcAnswers));
}


@override
int get hashCode => Object.hashAll([runtimeType,user,selectedTopic,showTasks,const DeepCollectionEquality().hash(generatedTasks),isLoadingTasks,taskError,const DeepCollectionEquality().hash(lastFeedback),isCheckingAnswers,activeSubject,const DeepCollectionEquality().hash(resultsHistory),greeting,testMode,testLocked,const DeepCollectionEquality().hash(currentTestTasks),showTestResult,const DeepCollectionEquality().hash(testIsCorrect),const DeepCollectionEquality().hash(testFeedback),isCheckingTest,canContinueTest,const DeepCollectionEquality().hash(textInputAnswers),const DeepCollectionEquality().hash(trueFalseAnswers),const DeepCollectionEquality().hash(mcAnswers)]);

@override
String toString() {
  return 'HomeState(user: $user, selectedTopic: $selectedTopic, showTasks: $showTasks, generatedTasks: $generatedTasks, isLoadingTasks: $isLoadingTasks, taskError: $taskError, lastFeedback: $lastFeedback, isCheckingAnswers: $isCheckingAnswers, activeSubject: $activeSubject, resultsHistory: $resultsHistory, greeting: $greeting, testMode: $testMode, testLocked: $testLocked, currentTestTasks: $currentTestTasks, showTestResult: $showTestResult, testIsCorrect: $testIsCorrect, testFeedback: $testFeedback, isCheckingTest: $isCheckingTest, canContinueTest: $canContinueTest, textInputAnswers: $textInputAnswers, trueFalseAnswers: $trueFalseAnswers, mcAnswers: $mcAnswers)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 UserModel user, String? selectedTopic, bool showTasks, List<Map<String, String>>? generatedTasks, bool isLoadingTasks, String? taskError, List<String>? lastFeedback, bool isCheckingAnswers, String? activeSubject, Map<String, List<ResultsEntry>> resultsHistory, String greeting, String testMode, bool testLocked, List<String> currentTestTasks, bool showTestResult, List<bool> testIsCorrect, List<String> testFeedback, bool isCheckingTest, bool canContinueTest, List<String> textInputAnswers, List<String?> trueFalseAnswers, List<String?> mcAnswers
});




}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? user = null,Object? selectedTopic = freezed,Object? showTasks = null,Object? generatedTasks = freezed,Object? isLoadingTasks = null,Object? taskError = freezed,Object? lastFeedback = freezed,Object? isCheckingAnswers = null,Object? activeSubject = freezed,Object? resultsHistory = null,Object? greeting = null,Object? testMode = null,Object? testLocked = null,Object? currentTestTasks = null,Object? showTestResult = null,Object? testIsCorrect = null,Object? testFeedback = null,Object? isCheckingTest = null,Object? canContinueTest = null,Object? textInputAnswers = null,Object? trueFalseAnswers = null,Object? mcAnswers = null,}) {
  return _then(_self.copyWith(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,selectedTopic: freezed == selectedTopic ? _self.selectedTopic : selectedTopic // ignore: cast_nullable_to_non_nullable
as String?,showTasks: null == showTasks ? _self.showTasks : showTasks // ignore: cast_nullable_to_non_nullable
as bool,generatedTasks: freezed == generatedTasks ? _self.generatedTasks : generatedTasks // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>?,isLoadingTasks: null == isLoadingTasks ? _self.isLoadingTasks : isLoadingTasks // ignore: cast_nullable_to_non_nullable
as bool,taskError: freezed == taskError ? _self.taskError : taskError // ignore: cast_nullable_to_non_nullable
as String?,lastFeedback: freezed == lastFeedback ? _self.lastFeedback : lastFeedback // ignore: cast_nullable_to_non_nullable
as List<String>?,isCheckingAnswers: null == isCheckingAnswers ? _self.isCheckingAnswers : isCheckingAnswers // ignore: cast_nullable_to_non_nullable
as bool,activeSubject: freezed == activeSubject ? _self.activeSubject : activeSubject // ignore: cast_nullable_to_non_nullable
as String?,resultsHistory: null == resultsHistory ? _self.resultsHistory : resultsHistory // ignore: cast_nullable_to_non_nullable
as Map<String, List<ResultsEntry>>,greeting: null == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String,testMode: null == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as String,testLocked: null == testLocked ? _self.testLocked : testLocked // ignore: cast_nullable_to_non_nullable
as bool,currentTestTasks: null == currentTestTasks ? _self.currentTestTasks : currentTestTasks // ignore: cast_nullable_to_non_nullable
as List<String>,showTestResult: null == showTestResult ? _self.showTestResult : showTestResult // ignore: cast_nullable_to_non_nullable
as bool,testIsCorrect: null == testIsCorrect ? _self.testIsCorrect : testIsCorrect // ignore: cast_nullable_to_non_nullable
as List<bool>,testFeedback: null == testFeedback ? _self.testFeedback : testFeedback // ignore: cast_nullable_to_non_nullable
as List<String>,isCheckingTest: null == isCheckingTest ? _self.isCheckingTest : isCheckingTest // ignore: cast_nullable_to_non_nullable
as bool,canContinueTest: null == canContinueTest ? _self.canContinueTest : canContinueTest // ignore: cast_nullable_to_non_nullable
as bool,textInputAnswers: null == textInputAnswers ? _self.textInputAnswers : textInputAnswers // ignore: cast_nullable_to_non_nullable
as List<String>,trueFalseAnswers: null == trueFalseAnswers ? _self.trueFalseAnswers : trueFalseAnswers // ignore: cast_nullable_to_non_nullable
as List<String?>,mcAnswers: null == mcAnswers ? _self.mcAnswers : mcAnswers // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}

}


/// @nodoc


class _HomeState implements HomeState {
  const _HomeState({required this.user, this.selectedTopic, this.showTasks = false, final  List<Map<String, String>>? generatedTasks, this.isLoadingTasks = false, this.taskError, final  List<String>? lastFeedback, this.isCheckingAnswers = false, this.activeSubject, final  Map<String, List<ResultsEntry>> resultsHistory = const {}, this.greeting = "Hallo Lehrling!", this.testMode = "bool", this.testLocked = false, final  List<String> currentTestTasks = const [], this.showTestResult = false, final  List<bool> testIsCorrect = const [], final  List<String> testFeedback = const [], this.isCheckingTest = false, this.canContinueTest = false, final  List<String> textInputAnswers = const [], final  List<String?> trueFalseAnswers = const [], final  List<String?> mcAnswers = const []}): _generatedTasks = generatedTasks,_lastFeedback = lastFeedback,_resultsHistory = resultsHistory,_currentTestTasks = currentTestTasks,_testIsCorrect = testIsCorrect,_testFeedback = testFeedback,_textInputAnswers = textInputAnswers,_trueFalseAnswers = trueFalseAnswers,_mcAnswers = mcAnswers;
  

@override final  UserModel user;
@override final  String? selectedTopic;
@override@JsonKey() final  bool showTasks;
 final  List<Map<String, String>>? _generatedTasks;
@override List<Map<String, String>>? get generatedTasks {
  final value = _generatedTasks;
  if (value == null) return null;
  if (_generatedTasks is EqualUnmodifiableListView) return _generatedTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  bool isLoadingTasks;
@override final  String? taskError;
 final  List<String>? _lastFeedback;
@override List<String>? get lastFeedback {
  final value = _lastFeedback;
  if (value == null) return null;
  if (_lastFeedback is EqualUnmodifiableListView) return _lastFeedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

// Feedback der KI-Korrektur
@override@JsonKey() final  bool isCheckingAnswers;
// Status für Antwortprüfung
@override final  String? activeSubject;
// aktuell aktives Fach
 final  Map<String, List<ResultsEntry>> _resultsHistory;
// aktuell aktives Fach
@override@JsonKey() Map<String, List<ResultsEntry>> get resultsHistory {
  if (_resultsHistory is EqualUnmodifiableMapView) return _resultsHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_resultsHistory);
}

// Ergebnisse pro Fach
@override@JsonKey() final  String greeting;
// Begrüßungstext
@override@JsonKey() final  String testMode;
// Testmodus
@override@JsonKey() final  bool testLocked;
// Sperrstatus für Testmodus-Buttons
// Wieder hinzugefügte Test-Felder
// Für alle Test-Typen gemeinsam
 final  List<String> _currentTestTasks;
// Sperrstatus für Testmodus-Buttons
// Wieder hinzugefügte Test-Felder
// Für alle Test-Typen gemeinsam
@override@JsonKey() List<String> get currentTestTasks {
  if (_currentTestTasks is EqualUnmodifiableListView) return _currentTestTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_currentTestTasks);
}

@override@JsonKey() final  bool showTestResult;
 final  List<bool> _testIsCorrect;
@override@JsonKey() List<bool> get testIsCorrect {
  if (_testIsCorrect is EqualUnmodifiableListView) return _testIsCorrect;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testIsCorrect);
}

 final  List<String> _testFeedback;
@override@JsonKey() List<String> get testFeedback {
  if (_testFeedback is EqualUnmodifiableListView) return _testFeedback;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_testFeedback);
}

@override@JsonKey() final  bool isCheckingTest;
@override@JsonKey() final  bool canContinueTest;
// Spezifisch für Text-Eingabe Tests
 final  List<String> _textInputAnswers;
// Spezifisch für Text-Eingabe Tests
@override@JsonKey() List<String> get textInputAnswers {
  if (_textInputAnswers is EqualUnmodifiableListView) return _textInputAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_textInputAnswers);
}

// Spezifisch für True/False Tests
 final  List<String?> _trueFalseAnswers;
// Spezifisch für True/False Tests
@override@JsonKey() List<String?> get trueFalseAnswers {
  if (_trueFalseAnswers is EqualUnmodifiableListView) return _trueFalseAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trueFalseAnswers);
}

// Spezifisch für MC Tests
 final  List<String?> _mcAnswers;
// Spezifisch für MC Tests
@override@JsonKey() List<String?> get mcAnswers {
  if (_mcAnswers is EqualUnmodifiableListView) return _mcAnswers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_mcAnswers);
}


/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeStateCopyWith<_HomeState> get copyWith => __$HomeStateCopyWithImpl<_HomeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeState&&(identical(other.user, user) || other.user == user)&&(identical(other.selectedTopic, selectedTopic) || other.selectedTopic == selectedTopic)&&(identical(other.showTasks, showTasks) || other.showTasks == showTasks)&&const DeepCollectionEquality().equals(other._generatedTasks, _generatedTasks)&&(identical(other.isLoadingTasks, isLoadingTasks) || other.isLoadingTasks == isLoadingTasks)&&(identical(other.taskError, taskError) || other.taskError == taskError)&&const DeepCollectionEquality().equals(other._lastFeedback, _lastFeedback)&&(identical(other.isCheckingAnswers, isCheckingAnswers) || other.isCheckingAnswers == isCheckingAnswers)&&(identical(other.activeSubject, activeSubject) || other.activeSubject == activeSubject)&&const DeepCollectionEquality().equals(other._resultsHistory, _resultsHistory)&&(identical(other.greeting, greeting) || other.greeting == greeting)&&(identical(other.testMode, testMode) || other.testMode == testMode)&&(identical(other.testLocked, testLocked) || other.testLocked == testLocked)&&const DeepCollectionEquality().equals(other._currentTestTasks, _currentTestTasks)&&(identical(other.showTestResult, showTestResult) || other.showTestResult == showTestResult)&&const DeepCollectionEquality().equals(other._testIsCorrect, _testIsCorrect)&&const DeepCollectionEquality().equals(other._testFeedback, _testFeedback)&&(identical(other.isCheckingTest, isCheckingTest) || other.isCheckingTest == isCheckingTest)&&(identical(other.canContinueTest, canContinueTest) || other.canContinueTest == canContinueTest)&&const DeepCollectionEquality().equals(other._textInputAnswers, _textInputAnswers)&&const DeepCollectionEquality().equals(other._trueFalseAnswers, _trueFalseAnswers)&&const DeepCollectionEquality().equals(other._mcAnswers, _mcAnswers));
}


@override
int get hashCode => Object.hashAll([runtimeType,user,selectedTopic,showTasks,const DeepCollectionEquality().hash(_generatedTasks),isLoadingTasks,taskError,const DeepCollectionEquality().hash(_lastFeedback),isCheckingAnswers,activeSubject,const DeepCollectionEquality().hash(_resultsHistory),greeting,testMode,testLocked,const DeepCollectionEquality().hash(_currentTestTasks),showTestResult,const DeepCollectionEquality().hash(_testIsCorrect),const DeepCollectionEquality().hash(_testFeedback),isCheckingTest,canContinueTest,const DeepCollectionEquality().hash(_textInputAnswers),const DeepCollectionEquality().hash(_trueFalseAnswers),const DeepCollectionEquality().hash(_mcAnswers)]);

@override
String toString() {
  return 'HomeState(user: $user, selectedTopic: $selectedTopic, showTasks: $showTasks, generatedTasks: $generatedTasks, isLoadingTasks: $isLoadingTasks, taskError: $taskError, lastFeedback: $lastFeedback, isCheckingAnswers: $isCheckingAnswers, activeSubject: $activeSubject, resultsHistory: $resultsHistory, greeting: $greeting, testMode: $testMode, testLocked: $testLocked, currentTestTasks: $currentTestTasks, showTestResult: $showTestResult, testIsCorrect: $testIsCorrect, testFeedback: $testFeedback, isCheckingTest: $isCheckingTest, canContinueTest: $canContinueTest, textInputAnswers: $textInputAnswers, trueFalseAnswers: $trueFalseAnswers, mcAnswers: $mcAnswers)';
}


}

/// @nodoc
abstract mixin class _$HomeStateCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory _$HomeStateCopyWith(_HomeState value, $Res Function(_HomeState) _then) = __$HomeStateCopyWithImpl;
@override @useResult
$Res call({
 UserModel user, String? selectedTopic, bool showTasks, List<Map<String, String>>? generatedTasks, bool isLoadingTasks, String? taskError, List<String>? lastFeedback, bool isCheckingAnswers, String? activeSubject, Map<String, List<ResultsEntry>> resultsHistory, String greeting, String testMode, bool testLocked, List<String> currentTestTasks, bool showTestResult, List<bool> testIsCorrect, List<String> testFeedback, bool isCheckingTest, bool canContinueTest, List<String> textInputAnswers, List<String?> trueFalseAnswers, List<String?> mcAnswers
});




}
/// @nodoc
class __$HomeStateCopyWithImpl<$Res>
    implements _$HomeStateCopyWith<$Res> {
  __$HomeStateCopyWithImpl(this._self, this._then);

  final _HomeState _self;
  final $Res Function(_HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? user = null,Object? selectedTopic = freezed,Object? showTasks = null,Object? generatedTasks = freezed,Object? isLoadingTasks = null,Object? taskError = freezed,Object? lastFeedback = freezed,Object? isCheckingAnswers = null,Object? activeSubject = freezed,Object? resultsHistory = null,Object? greeting = null,Object? testMode = null,Object? testLocked = null,Object? currentTestTasks = null,Object? showTestResult = null,Object? testIsCorrect = null,Object? testFeedback = null,Object? isCheckingTest = null,Object? canContinueTest = null,Object? textInputAnswers = null,Object? trueFalseAnswers = null,Object? mcAnswers = null,}) {
  return _then(_HomeState(
user: null == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as UserModel,selectedTopic: freezed == selectedTopic ? _self.selectedTopic : selectedTopic // ignore: cast_nullable_to_non_nullable
as String?,showTasks: null == showTasks ? _self.showTasks : showTasks // ignore: cast_nullable_to_non_nullable
as bool,generatedTasks: freezed == generatedTasks ? _self._generatedTasks : generatedTasks // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>?,isLoadingTasks: null == isLoadingTasks ? _self.isLoadingTasks : isLoadingTasks // ignore: cast_nullable_to_non_nullable
as bool,taskError: freezed == taskError ? _self.taskError : taskError // ignore: cast_nullable_to_non_nullable
as String?,lastFeedback: freezed == lastFeedback ? _self._lastFeedback : lastFeedback // ignore: cast_nullable_to_non_nullable
as List<String>?,isCheckingAnswers: null == isCheckingAnswers ? _self.isCheckingAnswers : isCheckingAnswers // ignore: cast_nullable_to_non_nullable
as bool,activeSubject: freezed == activeSubject ? _self.activeSubject : activeSubject // ignore: cast_nullable_to_non_nullable
as String?,resultsHistory: null == resultsHistory ? _self._resultsHistory : resultsHistory // ignore: cast_nullable_to_non_nullable
as Map<String, List<ResultsEntry>>,greeting: null == greeting ? _self.greeting : greeting // ignore: cast_nullable_to_non_nullable
as String,testMode: null == testMode ? _self.testMode : testMode // ignore: cast_nullable_to_non_nullable
as String,testLocked: null == testLocked ? _self.testLocked : testLocked // ignore: cast_nullable_to_non_nullable
as bool,currentTestTasks: null == currentTestTasks ? _self._currentTestTasks : currentTestTasks // ignore: cast_nullable_to_non_nullable
as List<String>,showTestResult: null == showTestResult ? _self.showTestResult : showTestResult // ignore: cast_nullable_to_non_nullable
as bool,testIsCorrect: null == testIsCorrect ? _self._testIsCorrect : testIsCorrect // ignore: cast_nullable_to_non_nullable
as List<bool>,testFeedback: null == testFeedback ? _self._testFeedback : testFeedback // ignore: cast_nullable_to_non_nullable
as List<String>,isCheckingTest: null == isCheckingTest ? _self.isCheckingTest : isCheckingTest // ignore: cast_nullable_to_non_nullable
as bool,canContinueTest: null == canContinueTest ? _self.canContinueTest : canContinueTest // ignore: cast_nullable_to_non_nullable
as bool,textInputAnswers: null == textInputAnswers ? _self._textInputAnswers : textInputAnswers // ignore: cast_nullable_to_non_nullable
as List<String>,trueFalseAnswers: null == trueFalseAnswers ? _self._trueFalseAnswers : trueFalseAnswers // ignore: cast_nullable_to_non_nullable
as List<String?>,mcAnswers: null == mcAnswers ? _self._mcAnswers : mcAnswers // ignore: cast_nullable_to_non_nullable
as List<String?>,
  ));
}


}

// dart format on
