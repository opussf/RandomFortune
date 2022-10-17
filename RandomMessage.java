package com.snocap.mystored.api;

import java.util.*;

/**
 * use:
 * 	String message = new RandomMessage().randomMessage();
 * @author Dave Kong
 * @see <b>the King</b>
 */
public class RandomMessage {
	
	private Vector<String> messages = new Vector<String>();
	
	private void init() {
		messages.add("Yo momma so stupid, I said refund, she thought I said retard");
		messages.add("Yo momma so big, she is still be considered a planet");
		messages.add("Yo momma so slow, it takes her 2 hours to watch 60 Minutes");
		messages.add("Yo mamma so clumsy she got tangled up in a cordless phone.");
		messages.add("Yo mamma twice the man you are.");
		messages.add("Yo mamma mouth so big, she speaks in surround sound.");
		messages.add("Yo mamma's glasses are so thick she can see into the future.");
		messages.add("Yo mamma so stupid she thinks a quarterback is a refund!");
		messages.add("Yo mamma so stupid she sold her car for gasoline money!");
		messages.add("Yo mamma so stupid she called Dan Quayle for a spell check.");
		messages.add("Yo mamma so stupid she makes Beavis and Butt-Head look like Nobel Prize winners.");
		messages.add("Yo mamma so stupid she sits on the TV, and watches the couch!");
		messages.add("Yo mamma so poor when she goes to KFC, she has to lick other people's fingers!");
		messages.add("Yo mamma so poor she can't afford to pay attention!");
		messages.add("Yo mamma so hairy Bigfoot is taking HER picture!");
		messages.add("Yo mamma so short you can see her feet on her drivers lisence!");
		messages.add("Yo momma is so ugly, Freddy Kruger has nightmares about HER!!");
		messages.add("Yo momma so stupid she tried to commit suicide out the basement window");
		messages.add("Yo momma so big she seceded");
		messages.add("Yo momma so dim, black holes look bright");
		messages.add("Yo momma is so old she owes Jesus five bucks");
		messages.add("Yo momma is so nasty she has an affro with sideburns");
		messages.add("Yo momma so fat, she has an event horizon.");
		messages.add("Yo momma so fat, bypasses are built around her");
		messages.add("Yo momma so ugly, when she enters a room, she don't turn on the light, the dark runs away.");
		messages.add("Yo mamma so dense, she blocks neutrinos.");
		messages.add("How many software engineers does it take to change a lightbulb?  None, it is a hardware problem.");
		messages.add("How many hardware engineers does it take to change a lightbulb?  None, they will fix it through software");
		messages.add("Why did God invent whiskey.  To keep the Irish from taking over the world.");
		messages.add("\\/\\/3 4r3 t|-|3 |-|4xx0rz");
		messages.add("All your base are belong to us");
		messages.add("This child is my friend. Occasionally it also becomes emergency provisions.");
		messages.add("'Rex unto my cleeb, and thou shalt have everlasting blort.' - Zorp 3:16");
		messages.add("Plunk your magic Twanger, Froggy");
		messages.add("I see F, you see K");
		messages.add("Atheism is a non-prophet organization.");
		messages.add("Auntie Em, Hate you, hate Kansas, taking the dog. Dorothy.");

		messages.add("I have gone to find myself.  If I get back before I return, keep me here.");
		messages.add("Indecision is the key to flexibility");
		messages.add("Death is but a doorway.  Here, let me get that for you");
		messages.add("Genius is 1 percent inspiration and 99% perspiration, which is why engineers sometimes smell really bad.");
		messages.add("It could be that the purpose of your life is only to serve as a warning to others.");
		messages.add("Mediocrity: It takes a lot less time and most people won't notice the difference until it's too late.");
		messages.add("Always remember that you are unique. Just like everybody else.");
		messages.add("The secret to success is knowing who to blame for your failures.");
		messages.add("You aren't being paid to believe in the power of your dreams.");
		messages.add("Of course, just because we've heard a spine-chilling, blood-curdling scream of the sort to make your very marrow freeze in your bones doesn't automatically mean there's anything wrong.");
		messages.add("Don't panic");
		messages.add("Gravity is a habit that is hard to shake off.");
		messages.add("A horse walks into a bar, bartender looks up and asks, 'So why the long face?'");
		messages.add("IMAGINATION: USE IT AS A WEAPON!");

		messages.add("I got 3 words for you...  NO");
			messages.add("Many a small thing has been made large by the right kind of advertising. - Mark Twain");
		messages.add("Let no man pull you low enough to hate him. - Martin Luther King ");
		messages.add("Give a man a fire and he's warm for the day. But set fire to him and he's warm for the rest of his life.");

		messages.add("There are 10 types of people.  Those that understand binary and those that don't.");
		messages.add("Everything I ever learned, I learned from Ron Jeremy and the family dog.");

		messages.add("What type of beans are werewolf's favorite?  Human Beings");
		messages.add("If pest control technicians kill pests, what do quality control technicians do?");
		messages.add("Basic dimensions: I have no tolerance for them.");

		messages.add("If vegetarians eat only vegetables, what do humanitarians eat?");
		
	}

	/**
	 * randomly picks a message to return
	 * @return String
	 */
	public String randomMessage() {
		init();
		Integer sdlkskhdf = new Random().nextInt(messages.size());
		return messages.get(sdlkskhdf);
	}
}

