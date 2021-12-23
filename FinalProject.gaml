/**
* Name: FinalProject
* Based on the internal empty template. 
* Author: Yuanhao Wang, Alexander Selivanov
* Tags: 
*/


model FinalProject

global {
	int numberOfPartyPeople <- 2;
	int numberOfChillPeople <- 2;
	int numberOfBars <- 1;
	int numberOfConcerts <- 1;
	
	init {
		create PartyPeople number:numberOfPartyPeople;
		create ChillPeople number: numberOfChillPeople;
		create Bars number: numberOfBars;
		create Concerts number:numberOfConcerts;
	}
}

species PartyPeople skills:[fipa,moving]
{	
	// Personal trait
	int noiseDegree <- rnd(10);
	
	// Shop attributes preference
	float pref_lightshow <- rnd(9) / 10;
	float pref_speakers <- rnd(9) / 10;
	float pref_band <- rnd(9) / 10;
	float pref_size <- rnd(9) / 10;
	
	point targetLocation <- nil;
	float utility <- 0.0;
	point barLocation <- nil;
	float barUtility <- 0.0;
	point concertLocation <- nil;
	float concertUtility <- 0.0;
	
	
	// Party people is looking for a place to go
	reflex LookingForFun when:targetLocation = nil
	{
		do wander;
	}
	
	// Calculate bar utility
	reflex CalculateBarUtility when:utility = 0.0
	{
		ask Bars closest_to(location){
			myself.barUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band) + (myself.pref_size * self.size);
			write myself.name + " bar utility is " + myself.barUtility;
			myself.barLocation <- self.location;
		}
	}
	
	
	// Calculate concert utility
	reflex CalculateConcertUtility when:utility = 0.0
	{
		ask Concerts closest_to(location){
			myself.concertUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band) + (myself.pref_size * self.size);
			write myself.name + " concert utility is " + myself.concertUtility;
			myself.concertLocation <- self.location;	
		}
	}
	
	// Compare the utility and choose a place to go
	reflex PickAPlace when:utility = 0.0
	{
		if barUtility >= concertUtility{
			utility <- barUtility;
			targetLocation <-barLocation;
		}
		else{
			utility <- concertUtility;
			targetLocation <- concertLocation;
		}
		write "-----" + name + " final utility is " + utility;
	}
	
	// Go to target location
	reflex GoToTarget when:targetLocation != nil
	{
		do goto target:targetLocation;
	}
	
	// Interact with chill people
	reflex handle_requests when: !empty(requests) 
	{
		message m <- (requests at 0);
		list<string> contents <- m.contents;
		string content <- contents[0];
		if content = 'request attributes' {
			do agree with: (message: m, contents: [noiseDegree]);
		}
	}
	
	aspect base {
		draw circle(1) color: #red;	
	}
}

species ChillPeople skills:[fipa,moving] 
{
	// Personal trait
	int acceptNoiseDegree <- rnd(10);
	
	// Shop attributes preference
	float pref_lightshow <- rnd(9) / 10;
	float pref_speakers <- rnd(9) / 10;
	float pref_band <- rnd(9) / 10;
	float pref_size <- rnd(9) / 10;
	
	point targetLocation <- nil;
	float utility <- 0.0;
	point barLocation <- nil;
	float barUtility <- 0.0;
	point concertLocation <- nil;
	float concertUtility <- 0.0;
	list<PartyPeople> PartyPeopleAtBar <- [];
	bool conversationStarted <- false;
	
	// Chill people is looking for a place to go
	reflex LookingForFun when:targetLocation = nil
	{
		do wander;
	}
	
	// Calculate bar utility
	reflex CalculateBarUtility when:utility = 0.0
	{
		ask Bars closest_to(location){
			myself.barUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band) + (myself.pref_size * self.size);
			write myself.name + " bar utility is " + myself.barUtility;
			myself.barLocation <- self.location;
		}
	}
	
	
	// Calculate concert utility
	reflex CalculateConcertUtility when:utility = 0.0
	{
		ask Concerts closest_to(location){
			myself.concertUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band) + (myself.pref_size * self.size);
			write myself.name + " concert utility is " + myself.concertUtility;
			myself.concertLocation <- self.location;	
		}
	}
	
	// Compare the utility and choose a place to go
	reflex PickAPlace when:utility = 0.0
	{
		if barUtility >= concertUtility{
			utility <- barUtility;
			targetLocation <-barLocation;
		}
		else{
			utility <- concertUtility;
			targetLocation <- concertLocation;
		}
		write "-----" + name + " final utility is " + utility;
	}
	
	// Go to target location
	reflex GoToTarget when:targetLocation != nil
	{
		do goto target:targetLocation;
	}
	
	// Start the conversation with party people who are at the bar
	reflex MeetPartyPeople when:targetLocation = barLocation and location = barLocation
	{
		// Create a list of party poeple who is at the bar
		ask agents of_species PartyPeople
		{
			if self.location = myself.barLocation and !(self in myself.PartyPeopleAtBar){
				myself.PartyPeopleAtBar << self;	
			}
		}
		
//		write PartyPeopleAtBar + " are currently in the bar";
		// If there are party people at the bar
		if PartyPeopleAtBar != []{
			do start_conversation (to :: PartyPeopleAtBar, protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['request attributes']);
		}
		
	}
	
	// Interact with party people at the bar
	reflex handle_agrees when: !empty(agrees) {
		int highestNoiseDegree <- -1;
		
		// Find the highest noise degree
		loop a over: agrees {
			list<int> contents <- a.contents;
			int noiseDegree <- contents[0];
			
			if highestNoiseDegree < noiseDegree{
				highestNoiseDegree <- noiseDegree;
			}
		}
		
		if acceptNoiseDegree < highestNoiseDegree{
			write name + " can accept noise " + acceptNoiseDegree + " and current noise is " + highestNoiseDegree;
			write name + ": You guys are too loud. I'm going to concert.";
			targetLocation <- concertLocation;
		}
		else{
			write name + " can accept noise " + acceptNoiseDegree + " and current noise is " + highestNoiseDegree;
			write name + ": I like this bar";
		}
		
	}
		
	aspect base {
		draw circle(1) color: #green;
	}
}

species Bars 
{
	float band <- rnd(9)/10;
	float lightshow <- rnd(9) / 10;
	float speakers <- rnd(9) / 10;
	float size <- rnd(9) / 10; 
	
	aspect base {
		draw square(4) color: #black;
	}
}

species Concerts 
{
	float band <- rnd(9)/10;
	float lightshow <- rnd(9) / 10;
	float speakers <- rnd(9) / 10;
	float size <- rnd(9) / 10; 
	
	aspect base {
		draw triangle(4) color: #blue;
	}
}

experiment FinalProject type:gui {
	output {
		display myDisplay {
			// Display the species with the created aspects
			species Bars aspect:base;
			species Concerts aspect:base;
			species PartyPeople aspect:base;
			species ChillPeople aspect:base;
		}
	}
}