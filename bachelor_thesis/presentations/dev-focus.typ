= Development focus points

This document presents the different focus points for the development phase of the project I'd like to underline.

== Actual state

- The ICNML application cannot have any development anymore. Indeed, several errors in the pipeline makes it so that a developer 
  cannot push new feature on the app. 

- There's a real technical and security debt with running the app with Python 2.8. Upgrading the version of Python to at least 3.9+ would 
  be very interesting for the different libraries used

- The images on the application are served without any watermark or steganography. It is very easy to download a copy
  of the images, albeit the quality is lower than the ones the watermark is added to.

- The watermark added to the images are very easy to bypass. It's not resilient to image transformation neiter.

- There is a lot of dead code. For example, a role that is never used (), a feature that is not working on the prod server (Pianos).

- The cryptography is obscure at some points and can be hard to reason around or understand.

- The application itself is not very user-friendly and offers no "quality of life" features for researchers. For example, removing an image that was added to a trainer
  directory, removing a trainer directory, search by quality of the prints and/or marks, etc...

== Focus points for the dev phase

=== Ensure sound deployment

I have a strong urge to ensure maintanability of the application in the future. I would suggeset as the first 
focus point to have the application deployed to a new machine with an environment that is better controled
by the IT service of the ESC and where we can easily deploy and update the app. I'd suggest simplifying the 
deployment by not running the app as a Docker Swarm but a simple docker compose. If the ressources are available to 
me, I would estimate this task to take around 2 days to properly configure the reverse proxy and the import of the prod db 
on the new one as well as finding and copying the private GPG key ? (that's the big unknown)

Then having the dependencies of the application stored somewhere known and accessible to the ESC. A repo on the GitLab of the institution would do the trick. It's very important as it seems that the custom dependencies (MDmisc, NIST, etc...) are today only accessible on my machine and nowhere else ! I would estimate this to take about 1-2 hours. I have them on my machine so it's not a big task.

I would also suggest trying to upgrade the Python version so that the libraries can be upgraded as well to versions without known CVEs. I don't have a clear estimate for this.


=== Steganography on all images 

I'm very interested exploring the steganography that would be possible on the images to make it robust to image transformation. It would be a very interesting task and I'm quite motivated by researching the literature to understand the current state of it. Then discussing the possibilities with my supervisor and implementing it on every image served so that every images has a trace of the user it is served to. My estimate would be about 10 days for the research and the implementation.


=== User experience

It's important to understand that the app is not actively used for research today because of th ergonomics of the application. It would be interesting to rework some basic feature for the Trainer role especially as it's the one that is the most used today for the creation of folder to export for training. The basic feature like removing an image from a folder or deleting a folder would take about 2 days. 

Adding an algorithm for detecting quality and adding the filtering feature on quality would take longer. I'd estimate it to 5 days.
