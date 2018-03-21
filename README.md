# Enzyme-Notebook (Enzymatiq)
Udacity iOS Capstone Project

Welcome to Enzymatiq - an iOS app that is built for managing and documenting biochemical experiments! A notebook in your pocket!

The main features of this app allows the user to create an experiment, and then sub-class each step in the experiment with details on the various protocols and observations for each step in an experiment. 
The app also allows the user to take as many pictures of their work and uploads them directly to Firebase for storage, and can also be shared. 
Users can also request push notifications with customizable reminders when something in their experiment needs to be taken care of. 
Each step can be edited after creation, allowing users to continuously update their work. 
Users can also search for various protocols in the app using a custom Google Search Engine which is tailored towards (free) scientific websites.

As a plus, the theme of this app is Rick and Morty, since Rick is a genius scientist. (If you've never seen the show, hopefully you will be slightly more inclined after using this app!)

This app is hosted on Firebase - you will need a valid email or google account in order to log-in.

## Experiment Home View Controller
![img_1129](https://user-images.githubusercontent.com/32831099/37692999-c343c8c8-2c79-11e8-83ae-9093513439f1.PNG)

This is the home experiment screen. Each of the experiments will be shown in this tableView. New experiments can be added using the + icon in the navigation bar

## New Experiment View Controller, Calendar View Controller

![img_1131](https://user-images.githubusercontent.com/32831099/37693019-0629f2ac-2c7a-11e8-8f75-6c1483dfc612.PNG)
![img_1130](https://user-images.githubusercontent.com/32831099/37693023-1109c86e-2c7a-11e8-99fd-d2009f0c7e27.PNG)

For each new experiment, you must add a title, set the dates of the experiment (using the Calendar View Controller), and give a brief summary of your protocol. You will be able to update the protocol text at a later stage so don't freak out about getting each step during creation.

## Event View Controller

Let's switch gears from example, to a real life experiment which shows how the app can be used

![img_1133](https://user-images.githubusercontent.com/32831099/37693058-62d1520c-2c7a-11e8-8732-65772ce54393.PNG)

The textView contains the protocol from the NewExperimentViewController which can be edited. (This will change the firebase storage as well). The start and end dates are passed from the created Experiment and cannot be edited after creation. These dates are there to guide you, so don't keep postponing your experiment

The tableView lists out the different steps in the protocol textView. These can be created using the + icon on the top right.

By selecting one of the tableView cells, or tapping the + icon will lead you to the...

## Detail View Controller

![img_1135](https://user-images.githubusercontent.com/32831099/37693143-f012b9ee-2c7a-11e8-8096-59317a413196.PNG)

This is where most of the important information is kept. AND you can revisit this tableView Cell whenever you want and continuously update it with more information.

The first textView is for describing what you actually did! Be as detailed as you can, because 2 weeks from now at least your phone will be able to remember!

The second textView is for any observations you may have had. Things that caught your eye, or if you messed up just a little bit.

The top right camera button will instantiate the camera on your device (if available). Taking and accepting an image will upload the photo to Firebase storage, and will also download the image and place it in the collectionView at the bottom.

If you decide to cancel (on a new event), any information uploaded to Firebase WILL be deleted!

You can also send push notifications! If there are overlapping events, each event can be set as a unique push notification since it is always easy to forget some of the details.

![img_1134](https://user-images.githubusercontent.com/32831099/37693284-cffe2c8c-2c7b-11e8-88f2-a5122d254d50.PNG)

For any image that is loaded in the collection View, you are able to...

## Image Viewer View Controller

![img_1136](https://user-images.githubusercontent.com/32831099/37693312-062779a8-2c7c-11e8-9b7c-a8e69bf6c9b5.PNG)

You can zoom in on the image, and you can also instantiate an activityViewController to share/save the image as you please!

## Search View Controller

![img_1137](https://user-images.githubusercontent.com/32831099/37693334-3523c388-2c7c-11e8-8d31-0fc0377ff08b.PNG)

The other page on the main tab bar view controller, is a custom Google Search Engine! If you have a quick question, you can type your query in the textField and search through a custom search engine that is tailored towards free science websites such as researchgate.net. The top 10 results per query are shown, since that is capped by the Google API.


