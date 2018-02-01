# java_ops
Study guide for SRE of Java applications

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

Over-consumption of this memory indicates classloader leak, or too many internalized strings.


### Garbage Collector

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
* JMX (Java Management Extensions)
	* Resources are represented as objects called MBeans (Managed Beans).

Use profiling tools to see things such as objects created and removed, method CPU time, method calls, memory utilization, and more.

**Other tips:**

Check how many times the GC runs per minute, and how long each run lasts on average.  If these numbers are low, then heap allocation is typically not an issue.

Check the number of active threads.  A good tunable to tweak/test is max_threads.

You can run GC and take a memory snapshot.  Do this a few times and with different circumstances in your program's lifetime. Run a diff between 2 snapshots and analyze.

Frequent application redeploys can effect ClassLoader leaks, especially with Tomcat applications that use ThreadLocals.

In the application code, recommend using special reference objects, such as SoftReference and WeakReference objects.  This makes it easier for the GC to clean things up. (c.f., java.lang.ref package)




### How can I optimize my application or my runtime configuration?

Unclosed streams and connections are a bad practice.

Don't use ThreadLocal caches unless you really need to do it.

Use logging levels (debug, info, warn, error) -- too much logging in production is bad -- not enough logging in QA is bad.

Look at your pools and queues; there can be bottlenecks through wrong sizing.

Look at database access; what if you are loading too much data inefficiently. 



## Relevant links and sources

* https://en.wikipedia.org/wiki/Java_Management_Extensions
* https://www.howtoforge.com/tutorial/linux-swappiness/
* https://docs.oracle.com/javase/9/
* https://docs.oracle.com/javase/8/docs/
* https://www.toptal.com/java/hunting-memory-leaks-in-java
* https://tomcat.apache.org/tomcat-7.0-doc/index.html



