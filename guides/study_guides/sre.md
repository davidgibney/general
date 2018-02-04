
Study this:

https://landing.google.com/sre/book/index.html




## FAQ


**You need to distribute GiB or even TiB data from a single server to a couple thousand nodes, and also keep data up to date. It takes time to copy the data to one server. How would you reduce the time needed to update all the servers? Also, how would you make sure that the files were not corrupted during the copy?**

S3 could be a good intermediary.  Copy the data to S3 with Multi-part Upload.  To get fancy, and before starting, edit your AWS CLI configuration to increase the S3 concurrency for requests to be 20 or more (the default is less than this). Next, split up the list of files to be copied, and spawn separate threads or processes for each list of files to run an S3 API copy command.  S3 has managed transfer algorithms to ensure perfect file uploads (but you should add a custom header to each object that describes the md5 checksum of the object - because checksums are necessary to later verify download).  S3, being a managed service, also scales automatically for requests to the same data, so your thousand servers can download the data without slowing down each other's connections.

Another option is to build your own P2P service (BitTorrent).




**What is an HTTP Header**

HTTP Headers allow client and server to share additional information within the request or response.  Fields within an HTTP Header include the following:

* Accept
	* Acceptable media types
* Accept-Charset
	* Acceptable character sets
* Content-Length
	* length of the request body
* Cookie
* Content-MD5
* From
* Host
* User-Agent
* X-Forwarded-For




**What would be some good CloudWatch Metrics to alarm on?**

CPU Utilization, Billing, CPU Credit Balance, StatusCheckFailed, EBS Idle Time, disk_free (w/ agent), mem_free (w/ agent), HTTPCode_ELB_5XX_Count, RejectedConnectionCount, TargetConnectionErrorCount, UnhealthyHostCount, Throttles (Lambda), ConcurrentExecutions (Lambda), ....







**What is the difference between a process and a thread?**

A thread is a lightweight process. A thread is owned by a process. Each process has a separate stack, text, data and heap. Threads have their own stack, but share text, data and heap with the process. Threads all belonging to the same process can share some information between them. 







**what's the difference between ELB and ALB, what layers are those**

Per the well-known OSI model, load balancers generally run at Layer 4 (transport) or Layer 7 (application).

A Layer 4 load balancer works at the network protocol level and does not look inside of the actual network packets, remaining unaware of the specifics of HTTP and HTTPS. In other words, it balances the load without necessarily knowing a whole lot about it.

A Layer 7 load balancer is more sophisticated and more powerful. It inspects packets, has access to HTTP and HTTPS headers, and (armed with more information) can do a more intelligent job of spreading the load out to the target.

ELB - classic load balancer at this point
NLB - network load balancer
ALB - application load balancer

ALB offers support for context-based routing, even as for container-based applications.  An ALB is cheaper than an ELB, so where possibe, use ALB. 

If you need to handle insane numbers of requests, use NLBs.



[ Copy+paste from https://aws.amazon.com/blogs/aws/new-aws-application-load-balancer/ ]




**Name some of the TCP connections states**

* LISTEN – Server is listening on a port, such as HTTP
* SYNC-SENT – Sent a SYN request, waiting for a response
* SYN-RECEIVED – (Server) Waiting for an ACK, occurs after sending an ACK from the server
* ESTABLISHED – 3 way TCP handshake has completed




**What are differences between TCP/UDP?**

Reliable/Unreliable
Heavyweight/Lightweight
Ordered/Unordered
Stateful versus streaming
Header size

UDP is used for video streaming, DNS, VoIP, online games

TCP is used for transmitted data such as web, SSH, FTP, SMTP -- and maintains state

TCP has more processing overhead than UDP

TCP can stop on error for multiple reasons; UDP lets the application software deal with lost packets, errors, and retransmission timers

UDP can tolerate data loss (if some packets are lost in video stream, the worst outcome is that a few pixels are lost, for example)





**What is an inode?**

An inode is a data structure in Unix that contains metadata about a file. Some of the items contained in an inode are:
* mode (e.g., permissions, rwx)
* owner (e.g., UID, GID)
* size
* atime, ctime, mtime (access time, change time {permissions, owner}, modified time {file contents only})
* list of blocks of where the data actually is

The filename is present in the parent directory’s inode structure.



**What is the difference between a soft link and a hard link?**

Hardlink shares the same inode number as the source link. Softlink has a different inode number. Hardlinks are only valid in the same filesystem, softlinks can be across filesystems. 

A hardlink is useful when the source file is getting moved around, because renaming the source does not remove the hardlink connection. If you rename the source of a softlink, the softlink is broken -- hardlinks share the same inode, whereas softlink uses the source filename in its data portion.




**What is the difference between apache worker versus prefork?**

Prefork uses forks. Worker.c uses threads.  Prefork is the default in Apache. Worker.c is easier on resources, but is more complex.




**In AWS VPC, what is the difference between Network ACLs and Security Groups?**

https://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Security.html#VPC_Security_Comparison





**What is a blue/green deployment?**

A blue/green deployment is a change management strategy for releasing software. Blue/green deployments, (aka A/B deployments) require two identical environments that are configured the same way. While one environment is active and serving end users, the other environment remains idle. You would deploy the newest code to the idle environment (let's say it's the blue one), test it, and then switch the active site over from the green environment, to the blue one (usually by just doing a DNS or load balancer change).  If a problem is discovered later on, it is easy to roll back to the previous environment. 




**What does a SSL/TLS handshake look like? How does it work**

First, a typical TCP connection is established (handshake of SYN -> SYN/ACK -> ACK). Then,

1.  Client Hello

Information that the server needs to communicate with the client using SSL. This includes the SSL version number, cipher settings, session-specific data.

2.  Server Hello

Information that the server needs to communicate with the client using SSL. This includes the SSL version number, cipher settings, session-specific data.

3.  Authentication and Pre-Master Secret

Client authenticates the server certificate. (e.g. Common Name / Date / Issuer) Client (depending on the cipher) creates the pre-master secret for the session, Encrypts with the server's public key and sends the encrypted pre-master secret to the server.

4.  Decryption and Master Secret

Server uses its private key to decrypt the pre-master secret. Both Server and Client perform steps to generate the master secret with the agreed cipher.

5.  Encryption with Session Key

Both client and server exchange messages to inform that future messages will be encrypted.

 
Taken from here:  https://www.websecurity.symantec.com/security-topics/how-does-ssl-handshake-work

Another good link:  https://msdn.microsoft.com/en-us/library/windows/desktop/aa380513(v=vs.85).aspx





**In AWS Route53, what is an alias record?**

https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-choosing-alias-non-alias.html





