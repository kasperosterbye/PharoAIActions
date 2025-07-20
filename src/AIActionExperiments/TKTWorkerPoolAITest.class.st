Class {
	#name : 'TKTWorkerPoolAITest',
	#superclass : 'TKTWorkerPoolTest',
	#category : 'AIActionExperiments-TestExperiments',
	#package : 'AIActionExperiments',
	#tag : 'TestExperiments'
}

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testGetAvailableWorkerReturnsWorkerWhenFreeWorkersAreAvailable [
	| pool worker |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
	worker := pool getAvailableWorker.
	self assert: worker isNotNil.
	self assert: worker isFree.
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testInitialize [
	| pool |
	pool := TKTWorkerPool new.
	pool initialize.
	self assert: pool size equals: 0.
	self assert: pool workers isEmpty.
	self assert: pool name equals: 'Worker' , pool identityHash asString
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testInitializeSetsDefaultValues [
	| pool |
	pool := TKTWorkerPool new.
	self assert: pool size equals: 0.
	self assert: pool workers isEmpty.
	self assert: pool name equals: 'Worker' , pool identityHash asString.
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testIsFreeWhenAllWorkersAreFree [
	| pool |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
	self assert: pool isFree.
	pool stop.
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testNewWorkerIsCreatedAndStarted [
	| pool newWorker |
	pool := TKTWorkerPool new.
	pool name: 'test pool'.
	pool poolMaxSize: 4.
	pool start.
	newWorker := pool newWorker.
	self assert: newWorker isRunning.
	self assert: (pool workers includes: newWorker).
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testPrintOn [
	| pool stream |
	pool := TKTWorkerPool new.
	pool name: 'TestPool'.
	pool poolMaxSize: 5.
	pool start.
	stream := WriteStream on: String new.
	pool printOn: stream.
	self assert: stream contents equals: 'TKTWorkerPool(poolMaxSize: 5; busyWorkers: 0; freeWorkers: 0)'
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testPriorityAfterStart [
	| pool workerProcess newPriority doneSemaphore |
	newPriority := 32.
	pool := TKTWorkerPool new.
	pool name: 'Test pool'.
	pool poolMaxSize: 4.
	pool start.
	pool schedule: (TKTTask valuable: [ Semaphore new wait ]).
	doneSemaphore := Semaphore new.
	pool schedule: (TKTTask valuable: [ doneSemaphore signal ]).
	doneSemaphore waitTimeoutMilliseconds: 500.
	pool priority: newPriority.
	self assert: pool priority equals: newPriority.
	pool workers do: [ :each |
		workerProcess := each process process.
		self assert: workerProcess priority equals: newPriority ]
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testPurgeRemovesAllTasksFromQueue [

	| pool |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
	pool schedule: [ 1 + 1 ].
	pool schedule: [ 1 + 1 ].
	pool purge.
	self assert: pool size equals: 0
]

{ #category : 'accessing' }
TKTWorkerPoolAITest >> testReturnWorkerAddsWorkerToFreeWorkers [
	| pool worker |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
	worker := pool newWorker.
	pool returnWorker: worker.
	self assert: (pool workers includes: worker)
]

{ #category : 'tests' }
TKTWorkerPoolAITest >> testScheduleTaskExecutionSchedulesTaskCorrectly [
	| pool taskExecution |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.

	"Create a task execution"
	taskExecution := TKTTaskExecution new.
	taskExecution task: [ 1 + 1 ].

	"Schedule the task execution"
	pool scheduleTaskExecution: taskExecution.

	"Wait for the task to be executed"
	1 second wait.
	
	"Check that the task was executed"
	self deny: taskExecution isFinished .
]

{ #category : 'tests' }
TKTWorkerPoolAITest >> testSizeReturnsNumberOfWorkers [
	| pool |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
	pool schedule: [ 1 + 1 ]. 
	pool schedule: [ 1 + 1 ].
	pool schedule: [ 1 + 1 ].
	pool schedule: [ 1 + 1 ].
	1 second wait.
	self assert: pool workers size equals: 4.
]

{ #category : 'tests' }
TKTWorkerPoolAITest >> testWorkerPoolStopStopsWorkers [
	| pool |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.

	"Schedule some tasks to ensure workers are created"
	((1 to: 10) collect: [:i | pool future: [ 1 + 1 ]])
		do: [ :future | future waitForCompletion: 500 milliSeconds ].

	"Stop the pool"
	pool stop.

	"Verify that all workers are stopped"
	pool workers do: [ :worker | self deny: worker isRunning ]
]
