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
	aspect base {
		draw circle(1) color: #red;	
	}
}

species ChillPeople skills:[fipa,moving] 
{
	aspect base {
		draw circle(1) color: #green;
	}
}

species Bars 
{
	aspect base {
		draw square(4) color: #black;
	}
}

species Concerts 
{
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