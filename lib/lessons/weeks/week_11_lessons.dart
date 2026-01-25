// weeks/week_11_lessons.dart
import '../lesson_model.dart';

/// Week 11: Lifestyle & Structure
class Week11Lessons {
  static List<Lesson> getLessons() {
    return [
      Lesson(
        id: 'w11d1',
        week: 11,
        day: 1,
        title: 'Sleep and Recovery',
        subtitle: 'Rest as a foundation',
        content: '''
Sleep is not a luxury in recovery—it's essential. Your brain and body need rest to heal.

Poor sleep increases cravings, irritability, poor decision-making, and relapse risk.

Why Sleep Matters:
During sleep, your brain:
• Consolidates memories and learning
• Processes emotions
• Repairs neural damage from substance use
• Regulates hormones and neurotransmitters
• Clears toxins

Without adequate sleep, you're fighting recovery with one hand tied behind your back.

Common Sleep Problems in Early Recovery:
• Insomnia (difficulty falling or staying asleep)
• Nightmares
• Restless sleep
• Irregular sleep schedule
• Using sleep as avoidance

These often improve with time, but you can take steps to support better sleep now.

Sleep Hygiene Basics:

1. Consistent Sleep Schedule
Go to bed and wake up at the same time every day, even weekends.

2. Create a Bedtime Routine
Wind down 30-60 minutes before bed. No screens, dim lights, calming activities.

3. Optimize Your Sleep Environment
Dark, cool, quiet room. Comfortable bed. Minimize distractions.

4. Limit Caffeine and Sugar
Especially after 2 PM.

5. Exercise Regularly
But not within 3 hours of bedtime.

6. Avoid Naps
Or keep them short (20-30 minutes) and before 3 PM.

7. Manage Stress
Practice relaxation techniques before bed.

When to Seek Help:
If sleep problems persist for more than a few weeks or severely impact functioning, talk to a doctor.
''',
        keyPoints: [
          'Sleep is essential for brain healing and relapse prevention',
          'Poor sleep increases cravings and poor decision-making',
          'Create a consistent sleep schedule and bedtime routine',
          'Optimize your environment and limit caffeine',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'How would you rate your current sleep quality (1-10)?',
            hint: 'Be honest about how you\'re sleeping',
          ),
          ReflectionQuestion(
            question: 'What sleep hygiene habit do you need to improve?',
            hint: 'Consistent schedule, bedtime routine, environment',
          ),
          ReflectionQuestion(
            question: 'What is one change you\'ll make this week to improve your sleep?',
            hint: 'Realistic, specific action',
          ),
        ],
        estimatedMinutes: 13,
      ),
      Lesson(
        id: 'w11d2',
        week: 11,
        day: 2,
        title: 'Nutrition and Physical Health',
        subtitle: 'Fueling your recovery',
        content: '''
Substance use takes a toll on your body. Nutrition is part of healing.

You can't think clearly, manage emotions, or resist cravings when your body is depleted.

How Addiction Affects Nutrition:
• Substances often replace meals
• Nutritional deficiencies (vitamins, minerals)
• Digestive problems
• Poor blood sugar regulation
• Dehydration

Recovery is an opportunity to nourish your body again.

Basic Nutrition Principles:

1. Eat Regular Meals
Three meals a day plus healthy snacks. Don't skip meals.

2. Balance Your Plate
• Protein (lean meat, fish, beans, tofu)
• Complex carbs (whole grains, vegetables, fruit)
• Healthy fats (nuts, seeds, avocado, olive oil)
• Plenty of water

3. Limit Sugar and Processed Foods
These cause blood sugar spikes and crashes, which can trigger cravings.

4. Stay Hydrated
Drink water throughout the day. Many people are chronically dehydrated.

5. Consider Supplements
Talk to a doctor about whether you need:
• Multivitamin
• B-complex vitamins
• Magnesium
• Omega-3 fatty acids

Food and Mood:
What you eat affects how you feel.

Protein stabilizes blood sugar and neurotransmitters. Complex carbs provide steady energy. Omega-3s support brain health.

Junk food might feel comforting in the moment, but it doesn't serve your recovery.

Meal Planning for Recovery:
Plan meals ahead of time so you're not making food decisions when you're hungry and depleted.

Keep healthy snacks accessible. Cook in batches. Ask for support if needed.
''',
        keyPoints: [
          'Nutrition supports brain healing and emotional regulation',
          'Eat regular, balanced meals with protein, complex carbs, and healthy fats',
          'Limit sugar and processed foods to avoid blood sugar crashes',
          'Hydration and possible supplements support recovery',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'How would you rate your current nutrition (1-10)?',
            hint: 'Are you eating regular, balanced meals?',
          ),
          ReflectionQuestion(
            question: 'What nutritional habit do you need to improve?',
            hint: 'Regular meals, less sugar, more water, balanced plates',
          ),
          ReflectionQuestion(
            question: 'What is one change you\'ll make this week to improve your nutrition?',
            hint: 'Meal planning, healthier snacks, drinking more water',
          ),
        ],
        estimatedMinutes: 14,
      ),
      Lesson(
        id: 'w11d3',
        week: 11,
        day: 3,
        title: 'Exercise and Movement',
        subtitle: 'Physical activity as mood regulation',
        content: '''
Exercise is one of the most effective natural mood regulators available. It's also a powerful relapse prevention tool.

You don't have to become a gym rat. You just have to move your body.

Benefits of Exercise in Recovery:
• Reduces stress, anxiety, and depression
• Improves sleep quality
• Boosts mood through endorphin release
• Provides healthy structure and routine
• Builds self-esteem and confidence
• Reduces cravings
• Improves physical health damaged by substance use

Exercise as Healthy Coping:
When you feel stressed, anxious, or triggered, movement can shift your state.

A walk, a run, stretching, dancing—anything that gets your body moving can interrupt the urge to use.

Finding Movement You Enjoy:
You're more likely to stick with exercise if you enjoy it.

Options:
• Walking or hiking
• Running or jogging
• Yoga or Pilates
• Weightlifting or bodyweight exercises
• Swimming
• Cycling
• Dancing
• Martial arts
• Team sports
• Rock climbing

Try different things until you find what works for you.

Start Small:
You don't need to run a marathon. Start with 10-20 minutes a day.

Walk around the block. Do a beginner yoga video. Dance in your living room.

Consistency matters more than intensity.

Movement Goals:
Aim for at least 30 minutes of moderate activity most days of the week.

But any movement is better than none.
''',
        keyPoints: [
          'Exercise reduces stress, anxiety, depression, and cravings',
          'Movement provides healthy structure and boosts mood',
          'Find activities you enjoy to increase consistency',
          'Start small—any movement is better than none',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'How often do you currently exercise or move your body?',
            hint: 'Be honest about your current activity level',
          ),
          ReflectionQuestion(
            question: 'What type of movement do you enjoy (or think you might enjoy)?',
            hint: 'Walking, yoga, dancing, sports, gym',
          ),
          ReflectionQuestion(
            question: 'What is one realistic movement goal for this week?',
            hint: '10-minute walks, 2 yoga sessions, daily stretching',
          ),
        ],
        estimatedMinutes: 13,
      ),
      Lesson(
        id: 'w11d4',
        week: 11,
        day: 4,
        title: 'Daily Structure and Routine',
        subtitle: 'Building sustainable habits',
        content: '''
Structure and routine are protective factors in recovery. They create stability when life feels chaotic.

Addiction thrives in chaos. Recovery thrives in consistency.

Why Routine Matters:
• Reduces decision fatigue
• Creates predictability and safety
• Builds healthy habits
• Prevents idle time (which can lead to cravings)
• Provides a sense of accomplishment
• Supports sleep, nutrition, and self-care

The Danger of Too Much Unstructured Time:
Boredom and lack of structure are relapse triggers.

When you have nothing to do, your mind wanders to substances. Structure keeps you engaged and moving forward.

Building Your Daily Routine:

1. Morning Routine
Start your day with consistency:
• Wake up at the same time
• Hydrate
• Movement or exercise
• Healthy breakfast
• Check-in or journaling

2. Work/Activity Block
Productive time:
• Work, school, or job search
• Hobbies or creative projects
• Errands or household tasks

3. Midday Check-In
Pause to assess:
• How am I feeling?
• What do I need right now?
• Am I on track with my goals?

4. Evening Routine
Wind down intentionally:
• Dinner and connection with others
• Relaxing activity
• Reflection or gratitude practice
• Bedtime routine

5. Weekly Commitments
Schedule non-negotiable recovery activities:
• Therapy or counseling
• Support group meetings
• Self-care activities

Flexibility Within Structure:
Routine doesn't mean rigidity. Life happens. Adjust as needed.

The goal is consistency, not perfection.
''',
        keyPoints: [
          'Structure reduces decision fatigue and prevents boredom',
          'Build morning, midday, and evening routines',
          'Schedule weekly recovery commitments',
          'Consistency, not perfection, is the goal',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'How structured is your current daily routine (1-10)?',
            hint: 'Do you have consistent wake/sleep times, meals, activities?',
          ),
          ReflectionQuestion(
            question: 'What part of your day feels most chaotic or unstructured?',
            hint: 'Mornings, afternoons, evenings, weekends',
          ),
          ReflectionQuestion(
            question: 'What is one routine you\'ll create or strengthen this week?',
            hint: 'Morning routine, evening wind-down, weekly check-ins',
          ),
        ],
        estimatedMinutes: 14,
      ),
      Lesson(
        id: 'w11d5',
        week: 11,
        day: 5,
        title: 'Managing Stress and Boredom',
        subtitle: 'Two sneaky relapse triggers',
        content: '''
Stress and boredom are two of the most common relapse triggers. They're opposites, but both are dangerous.

Learning to manage both is critical for long-term recovery.

Stress: When Life Feels Overwhelming
You've already learned stress management techniques in Week 9.

The key reminder:
• Identify stressors early
• Problem-solve what you can
• Accept what you can't
• Use healthy coping skills
• Reach out for support

Stress becomes dangerous when you isolate and try to handle everything alone.

Boredom: When Life Feels Empty
Boredom is underestimated as a relapse trigger, but it's powerful.

When you're bored:
• Time feels slow
• You ruminate on cravings
• Using seems like the only interesting option
• You feel restless and agitated

Boredom often comes from:
• Lack of structure or purpose
• Loss of old (substance-using) activities without new ones
• Not engaging with life
• Avoiding discomfort

Combating Boredom:

1. Build a Boredom Menu
Create a list of 20+ activities you can do when bored:
• Go for a walk
• Call a friend
• Watch a favorite show
• Work on a hobby
• Clean or organize
• Read a book
• Exercise
• Cook something new

Keep this list accessible.

2. Engage with Life
Boredom is often a signal that you're not engaged.

Try new things. Explore interests. Connect with people. Create something.

3. Tolerate Discomfort
Sometimes boredom is just discomfort with stillness.

Not every moment needs to be filled. You can sit with boredom without needing to escape it.

The Balance:
Structure prevents boredom. Flexibility prevents stress.

Find the balance that works for you.
''',
        keyPoints: [
          'Stress and boredom are both major relapse triggers',
          'Stress requires problem-solving, acceptance, and support',
          'Boredom requires structure, engagement, and tolerating stillness',
          'Create a boredom menu of 20+ activities',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'When do you most often feel stressed? What triggers it?',
            hint: 'Times of day, situations, people',
          ),
          ReflectionQuestion(
            question: 'When do you most often feel bored?',
            hint: 'Evenings, weekends, idle time',
          ),
          ReflectionQuestion(
            question: 'Create a list of 10 activities you can do when stressed or bored.',
            hint: 'Healthy coping skills and engaging activities',
          ),
        ],
        estimatedMinutes: 13,
      ),
    ];
  }
}