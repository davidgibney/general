# java_ops
Study guide for typical operations work around Java applications.

## High level definitions

A quick brief on JVM, memory, GC, and more.


### JVM

Two types of JVM memory:
* heap memory
* non-heap memory

####  heap memory

* Stores runtime data represented by allocated instances
* This is where memory for new objects comes from, and is released by GC

*OutOfMemory* errors are thrown when heap space memory runs out.  Not to be suffered -- this indicates memory leaks, or you're simply not allocating enough memory.

#### non-heap memory

This is a permanent memory pool ("Permanent Generation") and is typically limited in size compared to what's allocated to heap memory.

* Stores class-level information such as class definitions and methods, constants, and internalized strings.
	* *deduplication with internalized strings*:  an intern() performed on several strings will ensure that strings having same content will share the same memory address

Over-consumption of this memory can indicate classloader leak, or too many internalized strings.


### Garbage Collector

GC can have three steps
* Mark
* Sweep
* Compact

Mark the garbage and sweep it up?  Mark means marking reachable memory (surviving objects).  Sweep will scan memory to find unmarked memory, and leaves only surviving objects. Compact will relocate marked objects to defrag free memory. 

There are four types of garbage collection in Java:
* Serial GC
* Parallel GC
* CMS GC
* G1 GC

"Serial" is not ideal for server environments as it suspends threads when it runs.  

"Parallel" is the default GC (aka Throughput Collectors), but this one also freezes other threads when it runs. 

"Concurrent Mark Sweep" uses multiple threads and offers shorter GC pauses.  It uses more CPU, but it has the advantage that your application will not stop responding while GC is running.  You cannot explicitly call GC if it is already running.

"Garbage First" is recommended for server environments, and is a better choice than CMS.  G1 has the advantages of CMS but is more efficient.  Still, a difference between G1 and CMS is that  G1 partitions the heap into separate regions. After marking, G1 will decide which partition to sweep on first.

You can enable a specific GC for your JVM, and also customize its attributes, such as GC threads, pause time, and heap size.

### Memory leaks

Two considerations with memory leaks: 
* the size of a leak
* the program's lifetime

A continuously running program will eventually run out of memory resources.

Memory leaks can have a lot of causes.  Some examples:
* thread local variables
* mutable static fields and collections (better to use constants?)
* temporary objects that don't get de-referenced

Can't always know when JVM will run GC.  It usually runs when memory is low or is less than what your program needs.

Excessive page swapping can effect the performance of memory cleanup.... Experiment with tweaking the OS swappiness level.

With typical defaults, if the JVM spends 98% of the time running GC and reclaims no more than 2% memory, then an *OutOfMemoryError* would be thrown.


### JMX

Java Management Extensions.  Use this to manage/monitor your JVM and applications.

JMX has a remote management level so you can access through the MBeanServer through connectors such as with JMS or RMI, or access it through adaptors such as SNMP or HTTP.

One could, for example, create a custom monitoring application that uses JMX to periodically poll for certain metrics, and even push this information into AWS CloudWatch as custom metrics.



## FAQ

### How can I debug memory leaks?

**Options:**
* Take a heap dump and look for clues
*  Run the program in some contrived way, force an OOM error, and analyze stack trace
*  Enable verbose GC
*  Enable profiling
*  Document symptoms; research any history in tickets/wikis to identify additional symptoms and causes

Bottom line:  solving memory leaks requires code review / code changes; and improving performance requires tweaking runtime configurations and JVM tunables, and of implementing software design best practices


**Tools:**
* jProfiler
* jProbe
* Memory Analyzer for Eclipse
* JetBrains dotMemory
* other heap analyzers
* strace
* JMX (Java Management Extensions)
	* Resources are represented as objects called MBeans (Managed Beans).

Use profiling tools to see things such as objects created and removed, method CPU time, method calls, memory utilization, and more.

**Other tips:**

Check how many times the GC runs per minute, and how long each run lasts on average.  If these numbers are low, then heap allocation is typically not an issue.

Check the number of active threads.  A good tunable to tweak/test is max_threads.

You can run GC and take a memory snapshot.  Do this a few times and with different circumstances in your program's lifetime. Run a diff between 2 snapshots and analyze.

Frequent application redeploys can effect ClassLoader leaks, especially with Tomcat applications that use ThreadLocals.

In the application code, recommend using special reference objects, such as SoftReference and WeakReference objects.  This makes it easier for the GC to clean things up. (c.f., java.lang.ref package)


### What are some common errors related to memory issues?

* java.lang.OutOfMemoryError: Java heap space

	* Could mean memory leak, too small heap size, or bad use of finalizers in the code 

* java.lang.OutOfMemoryError: PermGen space

	* Try increasing this space, or re-examine use of interned strings
 
* java.lang.OutOfMemoryError: Requested array size exceeds VM limit

	* The application or its APIs tried to request the allocation of an array larger than the heap size.  You could have a configuration issue or the program could have a bug.

* java.lang.OutOfMemoryError: request <size> bytes for <reason>. Out of swap space?

	* The OS might not have a large enough swap space, or another application on the OS is consuming too much memory, or there could be a native leak such as with library code.

* java.lang.OutOfMemoryError: <reason> <stack trace> (Native method)

	* A native method encountered an allocation error. This failure is detected in a JNI or a native method rather than in Java VM code.  	

### How can I optimize my application or my runtime configuration?

Unclosed streams and connections are a bad practice.

Don't use ThreadLocal caches unless you really need to do it.

Use logging levels (debug, info, warn, error) -- too much logging in production is bad -- not enough logging in QA is bad.

Look at your pools and queues; there can be bottlenecks through wrong sizing.

Look at database access; what if you are loading too much data inefficiently. 

(Tomcat) try enabling compression.

### What are JVM arguments?

Also called switches.

Hundreds exist, but there are generally three types:
* Standard options
* Non-standard X options
* Non-standard XX options

Examples:

* -XX
* -Xmx
* -Xms
* -Xss
* -Xns

Options for these arguments can include, but are not limited to, the following examples:

* -XX can be used to set sizes for Permanent Generation.  It also has several options for configuring GC.
* -Xms can set initial and minimum heap size.
* -Xmx can set the maximum heap size.
* -Xss can set thread stack size (where each thread stores its local execution state).



### What are some good acronyms to know?

* JAAS
	* Java Authentication and Activation Service
* JAR
	* Java Archive
* JCE
	* Java Cryptography Extension. JCE provides a framework and implementation for encryption, key generation and key agreement, and Message Authentication Code (MAC) algorithms.
* JDBC
	* Java Database Connectivity
* JIT
	* Just in Time
* JLS
	* Java Language Specification
* JNA
	* Java Native Access. Gives access to native shared libraries without using the Java Native Interface.
* JNDI
	* Java Naming and Directory Service
* JNI
	* Java Native Interface
* JMS
	* Java Messaging Service
* JMX
	* Java Management Extensions.  Use this to manage/monitor your JVM and applications.
* STW
	* Stop the world. This can happen when the GC needs to pause processes.


### What to do when a log file is too big and the volume is full?

Enable log rotation.  To immediately fix, do not just delete the file, because it is probably currently in use by the running program.  You could truncate the file, for example, by echoing "" and piping that into the file (overwrite).


## Relevant links and sources

* https://en.wikipedia.org/wiki/Java_Management_Extensions
* https://www.howtoforge.com/tutorial/linux-swappiness/
* https://docs.oracle.com/javase/9/
* https://docs.oracle.com/javase/8/docs/
* https://www.toptal.com/java/hunting-memory-leaks-in-java
* https://tomcat.apache.org/tomcat-7.0-doc/index.html
* https://en.wikipedia.org/wiki/Garbage_collection_%28computer_science%29
* http://www.oracle.com/webfolder/technetwork/tutorials/obe/java/gc01/index.html




