/**
* Name: FinalProject
* Based on the internal empty template. 
* Author: Yuanhao Wang, Alexander Selivanov
* Tags: 
*/


model FinalProject

global {
	int numberOfPartyPeople <- 30;
	int numberOfChillPeople <- 30;
	int numberOfRockFan <- 30;
	int numberOfBars <- 1;
	int numberOfConcerts <- 1;
	
	init {
		create PartyPeople number:numberOfPartyPeople;
		create ChillPeople number: numberOfChillPeople;
		create RockFan number: numberOfRockFan;
		create Bars number: numberOfBars;
		create Concerts number:numberOfConcerts;
	}
}

species PartyPeople skills:[fipa,moving]
{	
	// Personal trait
	int noiseDegree <- rnd(10);
	int generous <- rnd(10);
	bool BoughtPeopleDrink <- false;
	
	// Shop attributes preference
	float pref_lightshow <- rnd(9) / 10;
	float pref_speakers <- rnd(9) / 10;
	float pref_band <- rnd(9) / 10;
	float pref_size <- rnd(9) / 10;
	float pref_service <- rnd(9) / 10;
	
	point targetLocation <- nil;
	float utility <- 0.0;
	point barLocation <- nil;
	float barUtility <- 0.0;
	point concertLocation <- nil;
	float concertUtility <- 0.0;
	list<ChillPeople> ChillPeopleAtBar <- [];
	list<ChillPeople> BoughtDrinkList <- [];
	
	
	// Party people is looking for a place to go
	reflex LookingForFun when:targetLocation = nil
	{
		do wander;
	}
	
	// Calculate bar utility
	reflex CalculateBarUtility when:utility = 0.0
	{
		ask Bars closest_to(location){
			myself.barUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band)
			 					+ (myself.pref_size * self.size) + (myself.pref_service * self.service);
			write myself.name + " bar utility is " + myself.barUtility;
			myself.barLocation <- self.location;
		}
	}
	
	
	// Calculate concert utility
	reflex CalculateConcertUtility when:utility = 0.0
	{
		ask Concerts closest_to(location){
			myself.concertUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) 
									+ (myself.pref_band * self.band) + (myself.pref_size * self.size) + (myself.pref_service * self.service);
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
	
	// Tell Chill people noise degree
	reflex handle_requests when: !empty(requests) 
	{
		message m <- (requests at 0);
		list<string> contents <- m.contents;
		string content <- contents[0];
		if content = 'request noise degree' {
			do agree with: (message: m, contents: [noiseDegree]);
		}
	}
	
	// After chill people accept the drink
	reflex handle_agrees when: !empty(agrees) {
		loop a over:agrees{
			write 'agree message with content ' + string(a.contents);
			write name + ': Glad to hear that. $$$';
			BoughtPeopleDrink <- true;
		}
	}
	
	// After chill people refuse the drink
	reflex handle_failures when: !empty(failures) {
		loop f over:failures{
			write 'failure message with content ' + string(f.contents);
			write name + ': Enjoy your night. $$$';
			BoughtPeopleDrink <- false;
		}
	}
	
	// Interact with chill people
	reflex MeetChillPeople when:targetLocation = barLocation and location = barLocation
	{
		// Create a list of chill poeple at the bar
		ask agents of_species ChillPeople
		{
			if self.location = myself.barLocation and !(self in myself.ChillPeopleAtBar){
				myself.ChillPeopleAtBar << self;	
			}
		}
		
		
		// If there are chill people at the bar, buy them a drink
		if ChillPeopleAtBar != [] and generous >= 5 and !BoughtPeopleDrink {
			loop c over:ChillPeopleAtBar{
				if !(c in BoughtDrinkList){
					write string(ChillPeopleAtBar) + " are in the bar, and " + c + " will be bought a drink";
					do start_conversation (to :: [c], protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['buy you a drink']);
					BoughtDrinkList << c;
					break;
				}
			}
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
	bool mood <- flip(0.5);
	bool DecideToStay <- false;
	int Interesting <- rnd(10);
	
	
	// Shop attributes preference
	float pref_lightshow <- rnd(9) / 10;
	float pref_speakers <- rnd(9) / 10;
	float pref_band <- rnd(9) / 10;
	float pref_size <- rnd(9) / 10;
	float pref_service <- rnd(9) / 10;
	
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
			myself.barUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band)
								 + (myself.pref_size * self.size) + (myself.pref_service * self.service);
			write myself.name + " bar utility is " + myself.barUtility;
			myself.barLocation <- self.location;
		}
	}
	
	
	// Calculate concert utility
	reflex CalculateConcertUtility when:utility = 0.0
	{
		ask Concerts closest_to(location){
			myself.concertUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers)
									 + (myself.pref_band * self.band) + (myself.pref_size * self.size) + (myself.pref_service * self.service);
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
	
	// Accept or refuse the drink from party people
	reflex handle_requests when: !empty(requests) 
	{
		message m <- (requests at 0);
		list<string> contents <- m.contents;
		string content <- contents[0];
		if content = 'buy you a drink' {
			if mood {
				do agree with: (message: m, contents: [string(name) + ': Thank you for the drink.']);
			}
			else {
				do failure (message: m, contents: [string(name) + ": Sorry, I don't want another drink."]);
			}
		}
		else if content = 'Invite to the bar' {
			if mood {
				do agree with: (message: m, contents: [string(name) + ': I would like to.']);
				targetLocation <- barLocation;
			}
			else {
				do failure (message: m, contents: [string(name) + ": Thank you for your invitation, but I would like to stay here."]);
			}
		}
	}
	
	// Decide whether to leave the bar or not based on party people's noise degree
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
			write name + ": You guys are too noisy. I'm going to leave.";
			targetLocation <- concertLocation;
		}
		else{
			write name + " can accept noise " + acceptNoiseDegree + " and current noise is " + highestNoiseDegree;
			write name + ": I like this place";
			DecideToStay <- true;
		}
		
	}
	
	// Start the conversation with party people who are at the bar
	reflex MeetPartyPeople when:targetLocation = barLocation and location = barLocation and !DecideToStay
	{
		// Create a list of party poeple who is at the bar
		ask agents of_species PartyPeople
		{
			if self.location = myself.barLocation and !(self in myself.PartyPeopleAtBar){
				myself.PartyPeopleAtBar << self;	
			}
		}

		// If there are party people at the bar, ask for their noise degree
		if PartyPeopleAtBar != []{
			do start_conversation (to :: PartyPeopleAtBar, protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['request noise degree']);
		}	
	}
		
	aspect base {
		draw circle(1) color: #green;
	}
}

species RockFan skills:[fipa,moving] 
{
	// Personal trait
	int LikeInterestingPeople <- rnd(10);
	bool sentInvitation <- false;
	
	// Shop attributes preference
	float pref_lightshow <- rnd(9) / 10;
	float pref_speakers <- rnd(9) / 10;
	float pref_band <- rnd(9) / 10;
	float pref_size <- rnd(9) / 10;
	float pref_service <- rnd(9) / 10;
	
	point targetLocation <- nil;
	float utility <- 0.0;
	point barLocation <- nil;
	float barUtility <- 0.0;
	point concertLocation <- nil;
	float concertUtility <- 0.0;
	list<ChillPeople> InterestingChillPeopleAtConcert <- [];
	list<ChillPeople> invited <- [];
	
	// Rock Fan is looking for a place to go
	reflex LookingForFun when:targetLocation = nil
	{
		do wander;
	}
	
	// Calculate bar utility
	reflex CalculateBarUtility when:utility = 0.0
	{
		ask Bars closest_to(location){
			myself.barUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band)
								 + (myself.pref_size * self.size) + (myself.pref_service * self.service);
			write myself.name + " bar utility is " + myself.barUtility;
			myself.barLocation <- self.location;
		}
	}
	
	
	// Calculate concert utility
	reflex CalculateConcertUtility when:utility = 0.0
	{
		ask Concerts closest_to(location){
			myself.concertUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers)
									 + (myself.pref_band * self.band) + (myself.pref_size * self.size) + (myself.pref_service * self.service);
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
	
	// After chill people accept the drink
	reflex handle_agrees when: !empty(agrees) {
		loop a over:agrees{
			write 'agree message with content ' + string(a.contents);
			write name + ": Let's go tegether. ^^^";
			targetLocation <- barLocation;
		}
	}
	
	// After chill people refuse the drink
	reflex handle_failures when: !empty(failures) {
		loop f over:failures{
			write 'failure message with content ' + string(f.contents);
			write name + ': Have a good night. ^^^';
			sentInvitation <- false;
		}
	}
	
	reflex MeetChillPeople when:targetLocation = concertLocation and location = concertLocation and !sentInvitation
	{
		// Create a list of chill poeple at the bar
		ask agents of_species ChillPeople
		{
			if self.location = myself.concertLocation and !(self in myself.InterestingChillPeopleAtConcert) and self.Interesting > myself.LikeInterestingPeople
			{
				myself.InterestingChillPeopleAtConcert << self;	
			}
		}
		
		
		// If there are chill people at the bar, buy them a drink
		if InterestingChillPeopleAtConcert != [] {
			loop c over:InterestingChillPeopleAtConcert{
				if !(c in invited){
					write string(InterestingChillPeopleAtConcert) + " are in the concert, and " + c + " will be invited";
					do start_conversation (to :: [c], protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['Invite to the bar']);
					invited << c;
					sentInvitation <- true;
					break;
				}
			}
		}
	}
	
	aspect base {
		draw circle(1) color: #purple;
	}
}

species Bars 
{
	float band <- rnd(9)/10;
	float lightshow <- rnd(9) / 10;
	float speakers <- rnd(9) / 10;
	float size <- rnd(9) / 10; 
	float service <- rnd(9) / 10;
	
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
	float service <- rnd(9) / 10;
	
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
			species RockFan aspect:base;
			species ChillPeople aspect:base;
		}
	}
}