# Enzyme-Notebook (Enzymatiq)
Udacity iOS Capstone Project

Welcome to Enzymatiq - an iOS app that is built for managing and documenting biochemical experiments! A notebook in your pocket!

The main features of this app include:

- Create an experimental plan with start/end dates and a general protocol
- Using this experimental plan, a user can describe, in detail, the various protocols and observations for each step in an     experiment.
- Users can also document observations with pictures
- Users can request customizable push notifications in the future in X Hours/minutes/seconds
- Users can edit each step of an experiment after creation, allowing them to continuously update their work
- Users can also search for various protocols/information in the app using a custom Google Search Engine which is tailored     towards (free) scientific websites.

As a plus, the theme of this app is Rick and Morty, since Rick is a genius scientist. (If you've never seen the show, hopefully you will be slightly more inclined after using this app!)

A valid email address/Google account is required in order to access this app

## Experiment Home View Controller
![img_1129](https://user-images.githubusercontent.com/32831099/37692999-c343c8c8-2c79-11e8-83ae-9093513439f1.PNG)

This is the home experiment screen. Each of the experiments will be shown in this tableView. New experiments can be added using the + icon in the navigation bar

## New Experiment View Controller, Calendar View Controller

![img_1131](https://user-images.githubusercontent.com/32831099/37693019-0629f2ac-2c7a-11e8-8f75-6c1483dfc612.PNG)
![img_1130](https://user-images.githubusercontent.com/32831099/37693023-1109c86e-2c7a-11e8-99fd-d2009f0c7e27.PNG)

For each new experiment, you must add a title, set the dates of the experiment (using the Calendar View Controller), and give a brief summary of your protocol. You will be able to update the protocol text at a later stage so don't worry too much  about getting every step during creation.

## Event View Controller

Let's switch gears from example, to a real life experiment I am conducting which shows how the app can be used

![img_1133](https://user-images.githubusercontent.com/32831099/37693058-62d1520c-2c7a-11e8-8732-65772ce54393.PNG)

The textView contains the protocol from the NewExperimentViewController which can be edited. The start and end dates are passed from the created Experiment and cannot be edited after creation. These dates are there to guide you, and provide an estimate from start of the experiment to the end.

The tableView lists out the different steps in the protocol textView. These can be created using the + icon on the top right.

By selecting one of the tableView cells, or tapping the + icon will lead you to the...

## Detail View Controller

![img_1135](https://user-images.githubusercontent.com/32831099/37693143-f012b9ee-2c7a-11e8-8096-59317a413196.PNG)

This is where most of the important information is kept. AND you can revisit this tableView Cell whenever you want and continuously update it with more information.

The first textView is for describing what you actually did. Be as detailed as you can, because 2 weeks from whenever you carry out your experiment, at least your phone will be able to remember!

The second textView is for any observations you may have had. Things that caught your eye or you noticed was different than usual, or if you messed up just a little bit.

The top right camera button will instantiate the camera on your device (if available). Taking and accepting an image will  place it in the collectionView at the bottom.

You can cancel an event before the 'SAVE DATA' button is pressed, or swipe the tableView cell to delete

You can also send customizable push notifications, in terms of message content and timing. If there are overlapping events, each event can be set as a unique push notification since it is always easy to forget some of the details.

![img_1134](https://user-images.githubusercontent.com/32831099/37693284-cffe2c8c-2c7b-11e8-88f2-a5122d254d50.PNG)

For any image that is loaded in the collection View, you are able to...

## Image Viewer View Controller

![img_1136](https://user-images.githubusercontent.com/32831099/37693312-062779a8-2c7c-11e8-9b7c-a8e69bf6c9b5.PNG)

You can zoom in on the image, and you can also instantiate an activityViewController to share/save the image as you please

## Search View Controller

![img_1137](https://user-images.githubusercontent.com/32831099/37693334-3523c388-2c7c-11e8-8d31-0fc0377ff08b.PNG)

The other page on the main tab bar view controller, is a custom Google Search Engine! If you have a quick question, you can type your query in the textField and search through a custom search engine that is tailored towards free science websites such as researchgate.net. The top 10 results per query are shown, since that is capped by the Google API.


## FIREBASE

This app is hosted on FireBase. The general structure of the database can be shown visually in the picture below.

<img width="760" alt="screen shot 2018-03-20 at 10 56 27 pm" src="https://user-images.githubusercontent.com/32831099/37696180-0c48afe4-2c92-11e8-87ca-8d2380e1f300.png">

child('Experiment') - holds all the different userIDs

child(userID) - gives each experiment created by a single user an autoKey to be used for differentiation

child(autoKey) - gives the details of the selected experiment (title, protocol, startDate, endDate).
                 Also contains title for each detailCell instantiated within the experiment (detailVC)
                 
child(detailTitle) "Overnight cultures" in this example - contains title of the task, observation text, descriptionText
                   Also contains another autoKey which is generated for each picture uploaded to Firebase. This autoKey is
                   stores the downloadURL for the imageData in order to populate the collectionView.

The pictures are stored separately in Firebase storage, since it is recommended that files > 1 MB aren't kept in the Real-Time database.
