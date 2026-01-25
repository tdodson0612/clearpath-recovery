// weeks/week_9_lessons.dart
import '../lesson_model.dart';

/// Week 9: Anxiety, Depression & Stress
class Week9Lessons {
  static List<Lesson> getLessons() {
    return [
      Lesson(
        id: 'w9d1',
        week: 9,
        day: 1,
        title: 'Understanding Co-occurring Disorders',
        subtitle: 'When mental health and addiction overlap',
        content: '''
Many people in recovery also struggle with mental health conditions like anxiety, depression, or PTSD.

These are called co-occurring disorders or dual diagnosis.

What Are Co-occurring Disorders?
This is when you have both a substance use disorder and a mental health condition.

Common co-occurring disorders:
• Depression
• Anxiety disorders
• PTSD
• Bipolar disorder
• ADHD
• Eating disorders

The Chicken or the Egg:
Sometimes mental health issues lead to substance use (self-medication). Sometimes substance use creates or worsens mental health problems.

Often, it's both. They feed each other in a vicious cycle.

Why This Matters:
If you only treat addiction without addressing mental health, you're more likely to relapse.

If you only treat mental health without addressing addiction, substances will continue to interfere with healing.

Both need attention.

Getting Proper Treatment:
Integrated treatment addresses both conditions simultaneously.

This might include:
• Therapy (CBT, DBT, trauma therapy)
• Medication (antidepressants, mood stabilizers, etc.)
• Support groups for both conditions
• Lifestyle changes (sleep, exercise, nutrition)

You don't have to choose between treating addiction or mental health. You can—and should—address both.
''',
        keyPoints: [
          'Co-occurring disorders mean having both addiction and mental health conditions',
          'Mental health and addiction often feed each other',
          'Both need treatment for lasting recovery',
          'Integrated treatment addresses addiction and mental health together',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'Do you struggle with anxiety, depression, or other mental health symptoms?',
            hint: 'Be honest about what you\'re experiencing',
          ),
          ReflectionQuestion(
            question: 'How does your mental health affect your substance use, and vice versa?',
            hint: 'What\'s the connection?',
          ),
          ReflectionQuestion(
            question: 'Are you currently receiving treatment for both conditions?',
            hint: 'If not, what\'s holding you back?',
          ),
        ],
        estimatedMinutes: 13,
      ),
      Lesson(
        id: 'w9d2',
        week: 9,
        day: 2,
        title: 'Managing Anxiety',
        subtitle: 'Calming the constant worry',
        content: '''
Anxiety is one of the most common mental health conditions, and it's often linked to substance use.

Understanding anxiety and learning to manage it is crucial for recovery.

What Is Anxiety?
Anxiety is your body's alarm system. It's meant to keep you safe from danger.

But for people with anxiety disorders, the alarm goes off even when there's no real threat.

Symptoms of anxiety:
• Racing thoughts
• Physical tension
• Rapid heartbeat
• Difficulty breathing
• Feeling on edge
• Trouble sleeping
• Constant worry

Anxiety and Substance Use:
Many people use substances to calm anxiety. It works in the short term but makes anxiety worse over time.

Substances disrupt your brain's natural ability to regulate stress, so when you stop using, anxiety often spikes.

This is temporary. Your brain will heal.

Managing Anxiety Without Substances:

1. Breathing Techniques
Deep, slow breathing activates your parasympathetic nervous system (the calm system).
Try: Breathe in for 4, hold for 4, out for 6.

2. Progressive Muscle Relaxation
Tense and release each muscle group from head to toe.

3. Challenge Anxious Thoughts
Ask: "What evidence do I have that this will happen?"
Consider: "What's a more realistic outcome?"

4. Limit Caffeine and Sugar
Both can increase anxiety.

5. Exercise
Physical activity burns off stress hormones.

6. Seek Professional Help
Therapy (especially CBT) and medication can be very effective for anxiety.
''',
        keyPoints: [
          'Anxiety is an overactive alarm system',
          'Substances temporarily calm anxiety but worsen it long-term',
          'Breathing, relaxation, and thought-challenging help manage anxiety',
          'Professional treatment (therapy and medication) is often necessary',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'What does anxiety feel like in your body?',
            hint: 'Physical sensations and symptoms',
          ),
          ReflectionQuestion(
            question: 'What situations or thoughts trigger your anxiety most?',
            hint: 'Identify your anxiety patterns',
          ),
          ReflectionQuestion(
            question: 'What is one anxiety management technique you\'ll try this week?',
            hint: 'Breathing, exercise, thought-challenging, seeking help',
          ),
        ],
        estimatedMinutes: 14,
      ),
      Lesson(
        id: 'w9d3',
        week: 9,
        day: 3,
        title: 'Managing Depression',
        subtitle: 'Finding light in the darkness',
        content: '''
Depression is more than just sadness. It's a persistent heaviness that affects how you think, feel, and function.

Many people in recovery struggle with depression, especially in early sobriety.

What Is Depression?
Depression is a mood disorder characterized by persistent low mood, loss of interest, and difficulty functioning.

Symptoms of depression:
• Persistent sadness or emptiness
• Loss of interest in activities
• Fatigue and low energy
• Difficulty concentrating
• Changes in sleep and appetite
• Feelings of worthlessness or guilt
• Thoughts of death or suicide

Depression and Substance Use:
Substances were often used to numb or escape depression. But they make depression worse by disrupting brain chemistry.

In early recovery, depression can intensify as your brain adjusts to functioning without substances.

This is called post-acute withdrawal syndrome (PAWS), and it can last weeks or months.

Managing Depression:

1. Behavioral Activation
Do things even when you don't feel like it. Action creates motivation, not the other way around.

2. Exercise
Even a 10-minute walk can improve mood.

3. Social Connection
Isolation worsens depression. Reach out, even when it's hard.

4. Sleep Hygiene
Depression and sleep problems are closely linked. Prioritize rest.

5. Challenge Negative Thoughts
Depression lies. Your thoughts are not facts.

6. Seek Professional Help
Therapy (especially CBT and IPT) and antidepressants can be lifesaving.

If you're experiencing suicidal thoughts, call 988 immediately.
''',
        keyPoints: [
          'Depression is persistent low mood that affects functioning',
          'Substances worsen depression by disrupting brain chemistry',
          'Behavioral activation means doing things even when you don\'t feel like it',
          'Professional help (therapy and medication) is often necessary',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'Do you experience symptoms of depression? Which ones?',
            hint: 'Be honest about what you\'re feeling',
          ),
          ReflectionQuestion(
            question: 'What is one activity you used to enjoy that you\'ve stopped doing?',
            hint: 'Consider trying it again, even if you don\'t feel motivated',
          ),
          ReflectionQuestion(
            question: 'Are you currently receiving treatment for depression?',
            hint: 'If not, are you willing to seek help?',
          ),
        ],
        estimatedMinutes: 13,
      ),
      Lesson(
        id: 'w9d4',
        week: 9,
        day: 4,
        title: 'Stress Management',
        subtitle: 'Handling pressure without substances',
        content: '''
Stress is a normal part of life. But for people in recovery, unmanaged stress is one of the biggest relapse triggers.

Learning to manage stress is essential for long-term sobriety.

What Is Stress?
Stress is your body's response to demands or threats. It activates your fight-or-flight system.

Short-term stress can be motivating. Chronic stress is harmful.

Signs of chronic stress:
• Constant worry
• Irritability and mood swings
• Difficulty sleeping
• Physical symptoms (headaches, stomach problems, tension)
• Difficulty concentrating
• Feeling overwhelmed

Stress and Relapse:
When stress builds without healthy outlets, substances start to look appealing again.

"I just need to take the edge off" becomes a dangerous thought.

Stress Management Strategies:

1. Identify Stressors
What's causing stress? Work? Relationships? Finances? Health?

2. Problem-Solve What You Can
Break big problems into small, manageable steps.

3. Accept What You Can't Control
Use radical acceptance for things outside your control.

4. Use Healthy Coping Skills
Exercise, meditation, talking to someone, creative outlets.

5. Time Management
Prioritize tasks. Say no when necessary. Delegate when possible.

6. Self-Care
Rest, nutrition, and boundaries reduce stress.

7. Ask for Help
You don't have to handle everything alone.

Building Stress Resilience:
You can't eliminate stress, but you can build resilience to handle it better.

Regular self-care, strong support, and healthy coping create a buffer against stress.
''',
        keyPoints: [
          'Chronic stress is a major relapse trigger',
          'Identify stressors and problem-solve what you can',
          'Accept what you can\'t control and use healthy coping',
          'Building resilience helps you handle stress without substances',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'What are your biggest sources of stress right now?',
            hint: 'List the top 3',
          ),
          ReflectionQuestion(
            question: 'Which stressors can you problem-solve, and which do you need to accept?',
            hint: 'Separate controllable from uncontrollable',
          ),
          ReflectionQuestion(
            question: 'What is one healthy way you can manage stress this week?',
            hint: 'Exercise, talking to someone, time management, self-care',
          ),
        ],
        estimatedMinutes: 14,
      ),
      Lesson(
        id: 'w9d5',
        week: 9,
        day: 5,
        title: 'When to Seek Professional Help',
        subtitle: 'Recognizing you need more support',
        content: '''
This app is a tool, but it's not a replacement for professional mental health treatment.

Knowing when to seek help—and actually doing it—can save your life.

Signs You Need Professional Help:

Mental Health Crisis:
• Suicidal thoughts or plans
• Self-harm urges or behaviors
• Severe panic attacks
• Hallucinations or delusions
• Complete inability to function

Persistent Symptoms:
• Depression that doesn't improve
• Anxiety that interferes with daily life
• Trauma symptoms (flashbacks, nightmares, hypervigilance)
• Mood swings or irritability
• Persistent insomnia

Relapse Risk:
• Strong, frequent cravings
• Romanticizing substance use
• Isolating from support
• Feeling hopeless about recovery

If any of these apply to you, reach out for help now.

Types of Professional Support:

Therapy:
• Individual counseling (CBT, DBT, EMDR, etc.)
• Group therapy
• Family therapy

Medication:
• Antidepressants
• Anti-anxiety medications
• Mood stabilizers
• Medications for addiction (MAT)

Psychiatry:
• Diagnosis and medication management

Crisis Support:
• 988 Suicide & Crisis Lifeline
• Crisis Text Line: Text HOME to 741741
• Local emergency room

How to Find Help:
• Ask your doctor for referrals
• Contact your insurance for in-network providers
• Use SAMHSA treatment locator: findtreatment.gov
• Try online therapy platforms (BetterHelp, Talkspace)
• Community mental health centers (sliding scale fees)

Barriers to Seeking Help:
Cost, stigma, fear, not knowing where to start—these are all real barriers.

But your life is worth fighting for. There are resources available.

Don't wait for a crisis. Seek help now.
''',
        keyPoints: [
          'This app is not a replacement for professional help',
          'Seek help for crisis symptoms, persistent issues, or relapse risk',
          'Options include therapy, medication, psychiatry, and crisis support',
          'Don\'t wait—reach out now if you\'re struggling',
        ],
        reflectionQuestions: [
          ReflectionQuestion(
            question: 'Are you currently receiving professional mental health treatment?',
            hint: 'Therapy, medication, psychiatry',
          ),
          ReflectionQuestion(
            question: 'What symptoms are you experiencing that might need professional help?',
            hint: 'Be honest with yourself',
          ),
          ReflectionQuestion(
            question: 'What\'s one step you can take this week to access professional support?',
            hint: 'Call a therapist, talk to your doctor, research resources',
          ),
        ],
        estimatedMinutes: 13,
      ),
    ];
  }
}