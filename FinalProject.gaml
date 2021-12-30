/**
* Name: FinalProject
* Based on the internal empty template. 
* Author: Yuanhao Wang, Alexander Selivanov
* Tags: 
*/

model FinalProject

global {
	int numberOfPartyPeople <- 20;
	int numberOfChillPeople <- 20;
	int numberOfRockFans <- 20;
	int numberOfPartyBreakers <- 20;
	int numberOfMerchEntusiasts <- 20;
	int numberOfBars <- 1;
	int numberOfConcerts <- 1;
	int numberOfRestaurant <- 1;
	int numberOfMerchShops <- 1;
	
	bool RestaurantIsFull <- false;
	bool PartyBroken <- false;
	
	list<point> listBarsLocation <- [];
	list<point> listConcertsLocation <- [];
	list<point> listMerchShopsLocation <- [];
	
	list<PartyPerson> listPartyPerson <- [];
	list<ChillPerson> listChillPerson <- [];
	list<RockPerson> listRockPerson <- [];
	list<PartyBreakerPerson> listPartyBreakerPerson <- [];
	list<MerchEntusiastPerson> listMerchEntusiastPerson <- [];
	
	int avgSocialInteractionPartyPerson <- 0;
	int avgSocialInteractionChillPerson <- 0;
	int avgSocialInteractionRockPerson <- 0;
	int avgSocialInteractionPartyBreakerPerson <- 0;
	int avgSocialInteractionMerchEntusiastPerson <- 0;
	
	init {
		create PartyPerson number: numberOfPartyPeople {
			listPartyPerson << self;	
		}
		create ChillPerson number: numberOfChillPeople {
			listChillPerson << self;
		}
		create RockPerson number: numberOfRockFans {
			listRockPerson << self;			
		}
		create PartyBreakerPerson number: numberOfPartyBreakers {
			listPartyBreakerPerson << self;
		}
		create MerchEntusiastPerson number: numberOfMerchEntusiasts {
			listMerchEntusiastPerson << self;
		}
		create Bars number: numberOfBars {
			listBarsLocation << self.location;	
		}
		create Concerts number: numberOfConcerts {
			listConcertsLocation << self.location;
		}
		create Restaurant number: numberOfRestaurant;
		create MerchShop number: numberOfMerchShops {
			listMerchShopsLocation << self.location;
		}
	}
	
	reflex calculateHappiness when: int(time) mod 10 = 0  {
		avgSocialInteractionPartyPerson <- 0;
		avgSocialInteractionChillPerson <- 0;
		avgSocialInteractionRockPerson <- 0;
		avgSocialInteractionPartyBreakerPerson <- 0;
		avgSocialInteractionMerchEntusiastPerson <- 0;
		
		loop p over: listPartyPerson {
			avgSocialInteractionPartyPerson <- avgSocialInteractionPartyPerson + p.social_interaction;
		}
		loop p over: listChillPerson {
			avgSocialInteractionChillPerson <- avgSocialInteractionChillPerson + p.social_interaction;
		}
		loop p over: listRockPerson {
			avgSocialInteractionRockPerson <- avgSocialInteractionRockPerson + p.social_interaction;
		}
		loop p over: listPartyBreakerPerson {
			avgSocialInteractionPartyBreakerPerson <- avgSocialInteractionPartyBreakerPerson + p.social_interaction;
		}
		loop p over: listMerchEntusiastPerson {
			avgSocialInteractionMerchEntusiastPerson <- avgSocialInteractionMerchEntusiastPerson + p.social_interaction;
		}
		
		avgSocialInteractionPartyPerson <- int(avgSocialInteractionPartyPerson / length(listPartyPerson));
		avgSocialInteractionChillPerson <- int(avgSocialInteractionChillPerson / length(listChillPerson));
		avgSocialInteractionRockPerson <- int(avgSocialInteractionRockPerson / length(listRockPerson));
		avgSocialInteractionPartyBreakerPerson <- int(avgSocialInteractionPartyBreakerPerson / length(listPartyBreakerPerson));
		avgSocialInteractionMerchEntusiastPerson <- int(avgSocialInteractionMerchEntusiastPerson / length(listMerchEntusiastPerson));
		
//		write 'AVG HAPPINESS (PARTY) ' + avgSocialInteractionPartyPerson;
//		write 'AVG HAPPINESS (CHILL) ' + avgSocialInteractionChillPerson;
//		write 'AVG HAPPINESS (ROCK) ' + avgSocialInteractionRockPerson;
//		write 'AVG HAPPINESS (PARTYBREAKER) ' + avgSocialInteractionPartyBreakerPerson;
//		write 'AVG HAPPINESS (MERCH) ' + avgSocialInteractionMerchEntusiastPerson;
	}
	
	reflex partyContinues when: int(time) mod 180 = 0 and PartyBroken {
		PartyBroken <- false;
	}
}


species Bars skills: [fipa]
{
	float band <- 0.1;
	float lightshow <- 0.2;
	float speakers <- 0.3;
	float size <- 0.5; 
	float service <- 0.4;
	
	reflex handle_requests when: !empty(requests)
	{
		message m <- (requests at 0);
		list<string> contents <- m.contents;
		string content <- contents[0];
		if content = 'request number of people' {
			list<Person> guests <- [];
			ask agents of_generic_species Person at_distance 1 {
				guests << self;
			}
			if !empty(guests) {
				do agree with: (message: m, contents: [length(guests)]);
			}
		}
	}
	
	aspect base {
		draw square(6) color: #black;
	}
}

species Concerts 
{
	float band <- 0.7;
	float lightshow <- 0.5;
	float speakers <- 0.4;
	float size <- 0.1; 
	float service <- 0.3;
	
	aspect base {
		draw triangle(6) color: #blue;
	}
}

species Restaurant skills: [fipa]
{
	list<agent> customers <- [];
	
	// Whether the restaurant is full or not
	reflex CountCustomers
	{
		if length(customers) <= 10 {
			ask agents at_distance 1 {
				if !(self in myself.customers) and length(myself.customers) <= 10 {
					myself.customers << self;
				}
			}
			RestaurantIsFull <- false;
		}
		else {
			RestaurantIsFull <- true;
		}
	}
	
	// Customers finish the food
	reflex handle_informs when: (!empty(informs)) {
		message informFromCustomer <- (informs at 0);
		list<string> contents <- informFromCustomer.contents;
		write string(informFromCustomer.sender) + " in the list " + customers + " is leaving.";
		remove informFromCustomer.sender from: customers;
		write name + " updated list is " + customers;
	}
	
	aspect base {
		draw hexagon(6) color: #orange;
	}
}

species MerchShop skills: [fipa]
{	
	aspect base {
		draw hexagon(6) color: #violet;
	}
}

species Person skills: [fipa, moving]
{
	// Shop attributes preference
	float pref_lightshow <- rnd(9) / 10;
	float pref_speakers <- rnd(9) / 10;
	float pref_band <- rnd(9) / 10;
	float pref_size <- rnd(9) / 10;
	float pref_service <- rnd(9) / 10;
	
	int hungry <- rnd(10);
	bool mood <- flip(0.6);
	int social_interaction <- 1;
	bool GoingToRestaurant <- false;
	
	point targetLocation <- nil;
	float utility <- 0.0;
	point barLocation <- nil;
	float barUtility <- 0.0;
	point concertLocation <- nil;
	float concertUtility <- 0.0;
	float partyBrokenAtTime <- 0.0;
	
	point restaurantLocation <- nil;
	list<Restaurant> RestaurantList <- nil;
	
	// Person is looking for a place to go
	reflex LookingForFun when: targetLocation = nil
	{
		do wander;
	}
	
	// Calculate bar utility
	reflex CalculateBarUtility when: utility = 0.0
	{
		ask Bars closest_to(location) {
			myself.barUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) + (myself.pref_band * self.band)
			 					+ (myself.pref_size * self.size) + (myself.pref_service * self.service);
			write myself.name + " closest bar utility is " + myself.barUtility;
			myself.barLocation <- self.location;
		}
	}
	
	// Calculate concert utility
	reflex CalculateConcertUtility when: utility = 0.0
	{
		ask Concerts closest_to(location) {
			myself.concertUtility <- (myself.pref_lightshow * self.lightshow) + (myself.pref_speakers * self.speakers) 
									+ (myself.pref_band * self.band) + (myself.pref_size * self.size) + (myself.pref_service * self.service);
			write myself.name + " closest concert utility is " + myself.concertUtility;
			myself.concertLocation <- self.location;
		}
	}
	
	// Compare the utility and choose a place to go
	reflex PickAPlace when: utility = 0.0
	{
		if barUtility >= concertUtility {
			utility <- barUtility;
			targetLocation <-barLocation;
		}
		else {
			utility <- concertUtility;
			targetLocation <- concertLocation;
		}
		write "-----" + name + " final utility is " + utility;
	}
	
	// Go to target location
	reflex GoToTarget when: targetLocation != nil
	{
		do goto target: targetLocation;
		// getting hungry
		if (int(time) mod (rnd(30) + 30) = 0) and !GoingToRestaurant {
			hungry <- hungry + 1;
		}		
	}
	
	// Decide to go to the restaurant
	reflex GetSomeFood when: hungry > 8 and !GoingToRestaurant
	{
		ask Restaurant {
			myself.targetLocation <- self.location;
			myself.restaurantLocation <- self.location;
			myself.RestaurantList << self;
		}
		write name + ": I'm starving, I will go get some food.";
		GoingToRestaurant <- true;
	}
	
	// Restaurant has no seats
	reflex WaitForSeats when: hungry > 8 and GoingToRestaurant and location distance_to restaurantLocation < 5 and location distance_to restaurantLocation > 0
	{
		if RestaurantIsFull {
			targetLocation <- nil;
			utility <- 0.0;
		}
		else {
			targetLocation <- restaurantLocation;
		}
	}
	
	// Leave restaurant
	reflex FinishFood when: location = restaurantLocation and GoingToRestaurant
	{
		if (int(time) mod (rnd(30) + 40) = 0) {
			write string(self) + ": I'm full now. I can get some fun again.";
			do start_conversation (to :: RestaurantList, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ["Check out"]);
			hungry <- 0;
			GoingToRestaurant <- false;
			utility <- 0.0;
			targetLocation <- nil;
		}
	}
	
	reflex handle_informs when: !empty(informs) {
		message inform <- (informs at 0);
		list<string> contents <- inform.contents;
		write "received inform from " + string(inform.sender);
		if contents[0] = 'Breaking party up' {
			targetLocation <- nil;
			partyBrokenAtTime <- time;
			social_interaction <- social_interaction + 1;
		}
	}
	
	reflex handle_requests when: !empty(requests)
	{
		message m <- (requests at 0);
		list<string> contents <- m.contents;
		string content <- contents[0];
		
		// Accept or refuse the drink from party people at the bar
		if content = 'buy you a drink' {
			if mood {
				do agree with: (message: m, contents: [string(name) + ': Thank you for the drink.']);
			}
			else {
				do failure (message: m, contents: [string(name) + ": Sorry, I don't want another drink."]);
			}
			social_interaction <- social_interaction + 1;
		}
		// Accept or refuse the invitation
		else if content = 'Invite to the bar' {
			if mood {
				do agree with: (message: m, contents: [string(name) + ': I would like to.']);
				targetLocation <- barLocation;
			}
			else {
				do failure (message: m, contents: [string(name) + ": Thank you for your invitation, but I would like to stay here."]);
			}
			social_interaction <- social_interaction + 1;
		}
		// Accept or refuse the merch offer
		else if content = 'offer buy merch' {
			if mood {
				do agree with: (message: m, contents: [string(name) + ': Thanks.']);
				utility <- 0.0;
			}
			else {
				do failure (message: m, contents: [string(name) + ": Thank you for the offer, but I don't want any."]);
				utility <- 0.0;
			}
			social_interaction <- social_interaction + 1;
		}
	}
	
	reflex walkItOff when: partyBrokenAtTime != 0.0 {
		float delta <- time - partyBrokenAtTime;
		if (delta) >= 10 {
			utility <- 0.0;
			partyBrokenAtTime <- 0.0;
		}
	}
}

species PartyPerson parent: Person
{
	// buy drinks
	
	// Personal traits
	int trait_outgoing <- 10;
	int trait_social <- 10;
	int trait_generous <- 6;
	
	bool BoughtPeopleDrink <- false;
	
	list<Person> peopleOfferedADrink <- [];
	
	reflex running {
		if int(time) mod (rnd(30) + 70) = 0 {
			BoughtPeopleDrink <- false;
		}
		if int(time) mod (rnd(30) + 250) = 0 {
			peopleOfferedADrink <- [];
		}
	}
	
	// After people accept the drink
	reflex handle_agrees when: !empty(agrees) {
		loop a over: agrees {
			write 'agree message with content ' + string(a.contents);
			write name + ': Glad to hear that. $$$';
			BoughtPeopleDrink <- true;
		}
		social_interaction <- social_interaction + 1;
	}
	
	// After people refuse the drink
	reflex handle_failures when: !empty(failures) {
		loop f over: failures {
			write 'failure message with content ' + string(f.contents);
			write name + ': Enjoy your night. $$$';
			BoughtPeopleDrink <- false;
		}
		social_interaction <- social_interaction + 1;
	}
	
	reflex interactWithOthers when: targetLocation in listBarsLocation and location in listBarsLocation {
		// Create a list of people at the bar
		list<Person> peopleAtBar <- [];
		ask agents of_generic_species Person {
			if self.location = myself.barLocation and !(self in peopleAtBar) {
				peopleAtBar << self;
			}
		}
		
		// If there are people at the bar, offer them a drink
		if !empty(peopleAtBar) and trait_generous >= 5 and trait_social >= 5 and trait_outgoing >= 3 and !BoughtPeopleDrink {
			loop p over: peopleAtBar {
				if !(p in peopleOfferedADrink) {
					write string(length(peopleAtBar)) + " are in the bar, and " + p + " will be bought a drink";
					do start_conversation (to :: [p], protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['buy you a drink']);
					peopleOfferedADrink << p;
					break;
				}
			}
		}
	}
	
	aspect base {
		draw circle(1) color: #red;	
	}
}

species ChillPerson parent: Person
{
	// leave bar when not social and noisy
	
	// Personal trait
	int trait_outgoing <- 6;
	int trait_social <- 6;
	int trait_quiet <- 5;

	bool DecideToStay <- false;

	bool conversationStarted <- false;
	
	
	reflex running {
		if int(time) mod (rnd(30) + 70) = 0 {
			DecideToStay <- false;
		}
	}
	
	// Decide whether to leave the bar or not
	reflex handle_agrees when: !empty(agrees) {
		message m <- (agrees at 0);
		list<int> contents <- m.contents;
		int numberOfPeople <- contents[0];
		
		if numberOfPeople >= 5 and trait_social <= 5 {
			if trait_outgoing >= 5 and trait_quiet >= 5 {
				write name + ": I like this place";
				DecideToStay <- true;
			}
			else {
				write name + ": I am tired of this place. I'm going to leave.";
				targetLocation <- concertLocation;
			}
		}
		else {
			write name + ": I like this place";
			DecideToStay <- true;
		}
		social_interaction <- social_interaction + 1;
	}
	
	// Start the conversation with party people who are at the bar
	reflex MeetPartyPeople when: targetLocation = barLocation and location = barLocation and !DecideToStay
	{
		Bars closest_bar <- nil;
		ask Bars closest_to(location)
		{
			closest_bar <- self;
			break;
		}
		if closest_bar != nil {
			do start_conversation (to :: [closest_bar], protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['request number of people']);
		}
	}
		
	aspect base {
		draw circle(1) color: #green;
	}
}

species RockPerson parent: Person
{
	// Personal trait
	int trait_outgoing <- 8;
	int trait_social <- 8;
	int trait_lazy <- 3;
	
	bool sentInvitation <- false;
	list<Person> invited <- [];
	
	reflex running {
		if int(time) mod (rnd(30) + 70) = 0 {
			sentInvitation <- false;
		}
		if int(time) mod (rnd(30) + 250) = 0 {
			invited <- [];
		}
	}
	
	// After chill people accept the invitation
	reflex handle_agrees when: !empty(agrees) {
		loop a over: agrees {
			write 'agree message with content ' + string(a.contents);
			write name + ": Let's go together. ^^^";
			targetLocation <- barLocation;
		}
		social_interaction <- social_interaction + 1;
	}
	
	// After chill people refuse the invitation
	reflex handle_failures when: !empty(failures) {
		loop f over: failures{
			write 'failure message with content ' + string(f.contents);
			write name + ': Have a good night. ^^^';
			sentInvitation <- false;
		}
		social_interaction <- social_interaction + 1;
	}

	reflex invitePeopleToTheBar when: targetLocation in listConcertsLocation and location in listConcertsLocation and !sentInvitation
	{
		// Create a list of interesting people in the concert
		list<Person> interestingPeopleAtConcert <- [];
		ask agents of_species MerchEntusiastPerson
		{
			if self.location = myself.concertLocation and !(self in interestingPeopleAtConcert) and (self.trait_outgoing + self.trait_social) >= 8
			{
				interestingPeopleAtConcert << self;
			}
		}
		
		// If there are interesting people in the concert, invite them to the bar.
		if !empty(interestingPeopleAtConcert) and trait_lazy <= 4 {
			loop c over: interestingPeopleAtConcert {
				if !(c in invited) {
					write string(length(interestingPeopleAtConcert)) + " are in the concert, and " + c + " will be invited to the bar";
					do start_conversation (to :: [c], protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['Invite to the bar']);
					social_interaction <- social_interaction + 1;
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

species PartyBreakerPerson parent: Person
{
	// Personal trait
	int trait_outgoing <- 6;
	int trait_social <- 4;
	int trait_misbehaving <- 9;
	
	bool wantToBreakParty <- false;
	
	reflex BreakTheParty when: hungry > 6 and location in listConcertsLocation and !PartyBroken and avgSocialInteractionPartyBreakerPerson > 0
	{
		if trait_misbehaving >= 9 {
			wantToBreakParty <- true;
		} else if trait_misbehaving >= 7 and trait_social <= 1 {
			wantToBreakParty <- true;
		} else if trait_outgoing <= 1 {
			wantToBreakParty <- true;
		} else {
			wantToBreakParty <- false;
		}
		
		if wantToBreakParty {
			list<Person> people <- [];
			ask agents of_generic_species Person at_distance 1 {
				people << self;
				write self.name;
			}
			
			if !empty(people) {
				write name + " is breaking up the concert";
				do start_conversation (to :: people, protocol :: 'fipa-contract-net', performative :: 'inform', contents :: ['Breaking party up']);
				social_interaction <- social_interaction + 1;
				PartyBroken <- true;
				wantToBreakParty <- false;
			}
		}
	}
	
	aspect base {
		draw circle(1) color: #yellow;
	}
}

species MerchEntusiastPerson parent: Person
{
	// Personal trait
	int trait_outgoing <- 5;
	int trait_social <- 5;
	int trait_friendly <- 8;
	
	bool atShop <- false;
	
	reflex goToMerchShop when: int(time) mod (rnd(120) + 30) = 0 and flip(0.4) {
		ask MerchShop closest_to(location) {
			myself.targetLocation <- self.location;
			break;
		}
	}
	
	reflex arrivedToShop when: location in listMerchShopsLocation and !atShop {
		bool offer <- false;
		atShop <- true;
		write 'ARRIVED TO SHOP';
		
		if trait_friendly >= 8 {
			if trait_outgoing >= 3 or trait_social >= 6 {
				offer <- true;
				write 'OFFER TRUE';
			}
		}
		
		if offer {
			ask MerchEntusiastPerson at_distance(1) {
				write self.name + " is in the shop, and will be offered merch";
				do start_conversation (to :: [self], protocol :: 'fipa-contract-net', performative :: 'request', contents :: ['offer buy merch']);
				social_interaction <- social_interaction + 1;
				break;
			}
		}
	}
	
	// After people accept the offer
	reflex handle_agrees when: !empty(agrees) {
		loop a over: agrees {
			write 'agree message with content ' + string(a.contents);
			write name + ": It fits you well.";
			utility <- 0.0;
			atShop <- false;
		}
		social_interaction <- social_interaction + 1;
	}
	
	// After people refuse the offer
	reflex handle_failures when: !empty(failures) {
		loop f over: failures{
			write 'failure message with content ' + string(f.contents);
			write name + ': I will try again next time.';
			utility <- 0.0;
			atShop <- false;
		}
		social_interaction <- social_interaction + 1;
	}
	
	aspect base {
		draw circle(1) color: #grey;
	}
}

experiment FinalProject type: gui {
	output {
		display chart refresh: every(100#cycle) {
		   chart "Average Social interaction" type: series {
		      data "PartyPerson" value: avgSocialInteractionPartyPerson color: #red;
		      data "ChillPerson" value: avgSocialInteractionChillPerson color: #green;
		      data "RockPerson" value: avgSocialInteractionRockPerson color: #blue;
		      data "PartyBreakerPerson" value: avgSocialInteractionPartyBreakerPerson color: #orange;
		      data "MerchEntusiastPerson" value: avgSocialInteractionMerchEntusiastPerson color: #violet;
		   }
		}

		display myDisplay {
			// Display the species with the created aspects
			species Bars aspect:base;
			species Concerts aspect:base;
			species Restaurant aspect:base;
			species MerchShop aspect:base;
			species PartyBreakerPerson aspect:base;
			species PartyPerson aspect:base;
			species RockPerson aspect:base;
			species ChillPerson aspect:base;
			species MerchEntusiastPerson aspect:base;
		}
	}
}
