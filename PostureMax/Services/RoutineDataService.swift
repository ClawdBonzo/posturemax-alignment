import Foundation

struct RoutineDataService {
    static let defaultRoutines: [(name: String, category: String, description: String, duration: Int, steps: [String], icon: String, difficulty: String, targets: [String])] = [
        // Desk Setup
        (
            name: "Ergonomic Desk Reset",
            category: "Desk Setup",
            description: "Optimize your workspace for perfect posture alignment",
            duration: 5,
            steps: [
                "Adjust chair height so feet are flat on floor",
                "Set monitor at eye level, arm's length away",
                "Position keyboard so elbows are at 90 degrees",
                "Place mouse close to keyboard",
                "Ensure lumbar support contacts lower back"
            ],
            icon: "desktopcomputer",
            difficulty: "beginner",
            targets: ["spine", "neck"]
        ),
        (
            name: "Standing Desk Transition",
            category: "Desk Setup",
            description: "Alternate between sitting and standing throughout the day",
            duration: 2,
            steps: [
                "Raise desk to elbow height",
                "Stand with weight evenly distributed",
                "Use an anti-fatigue mat",
                "Switch position every 30 minutes",
                "Keep monitor at eye level"
            ],
            icon: "figure.stand",
            difficulty: "beginner",
            targets: ["spine", "hips"]
        ),

        // Stretches
        (
            name: "Neck Release Flow",
            category: "Stretches",
            description: "Relieve neck tension and improve cervical alignment",
            duration: 8,
            steps: [
                "Chin tucks: 10 reps, hold 5 seconds each",
                "Ear-to-shoulder stretch: 30 seconds each side",
                "Neck rotations: 5 slow circles each direction",
                "Levator scapulae stretch: 30 seconds each side",
                "Suboccipital release: 60 seconds gentle pressure"
            ],
            icon: "figure.cooldown",
            difficulty: "beginner",
            targets: ["neck"]
        ),
        (
            name: "Upper Back Opener",
            category: "Stretches",
            description: "Open up the thoracic spine and relieve upper back tension",
            duration: 10,
            steps: [
                "Cat-cow stretches: 10 reps",
                "Thoracic spine rotation: 8 each side",
                "Thread the needle: 30 seconds each side",
                "Foam roller thoracic extension: 2 minutes",
                "Wall angels: 10 slow reps",
                "Doorway pec stretch: 30 seconds each side"
            ],
            icon: "figure.flexibility",
            difficulty: "beginner",
            targets: ["shoulders", "spine"]
        ),
        (
            name: "Hip Flexor Reset",
            category: "Stretches",
            description: "Counter the effects of prolonged sitting on your hips",
            duration: 12,
            steps: [
                "Half-kneeling hip flexor stretch: 60 seconds each",
                "Pigeon pose: 60 seconds each side",
                "90/90 hip stretch: 45 seconds each",
                "Supine figure-4 stretch: 60 seconds each",
                "Standing quad stretch: 30 seconds each",
                "Hip circles: 10 each direction"
            ],
            icon: "figure.run",
            difficulty: "intermediate",
            targets: ["hips"]
        ),

        // Strengthening
        (
            name: "Posture Power Circuit",
            category: "Strengthening",
            description: "Build the muscles that support proper posture",
            duration: 15,
            steps: [
                "Plank hold: 30 seconds x 3",
                "Bird-dog: 10 reps each side",
                "Superman hold: 15 seconds x 5",
                "Band pull-aparts: 15 reps x 3",
                "Dead bug: 10 reps each side",
                "Glute bridges: 15 reps x 3"
            ],
            icon: "figure.strengthtraining.traditional",
            difficulty: "intermediate",
            targets: ["spine", "shoulders", "hips"]
        ),
        (
            name: "Core Stability Foundation",
            category: "Strengthening",
            description: "Build a stable core to support your spine",
            duration: 12,
            steps: [
                "Dead bug holds: 10 reps each side",
                "Side plank: 20 seconds each side x 3",
                "Pallof press: 10 reps each side",
                "Bird-dog: 10 reps each side",
                "Hollow body hold: 20 seconds x 3"
            ],
            icon: "figure.core.training",
            difficulty: "intermediate",
            targets: ["spine"]
        ),

        // Mobility
        (
            name: "Morning Mobility Flow",
            category: "Mobility",
            description: "Start your day with full-body movement",
            duration: 10,
            steps: [
                "Cat-cow: 10 slow breaths",
                "World's greatest stretch: 5 each side",
                "Spinal twists: 30 seconds each side",
                "Shoulder dislocates: 10 reps",
                "Hip 90/90 switches: 10 reps",
                "Ankle circles: 10 each direction"
            ],
            icon: "sunrise.fill",
            difficulty: "beginner",
            targets: ["neck", "spine", "shoulders", "hips"]
        ),
        (
            name: "Shoulder Mobility Routine",
            category: "Mobility",
            description: "Restore full range of motion to your shoulders",
            duration: 10,
            steps: [
                "Arm circles: 15 each direction",
                "Cross-body shoulder stretch: 30 seconds each",
                "Shoulder dislocates with band: 10 reps",
                "Wall slides: 10 slow reps",
                "Sleeper stretch: 30 seconds each side",
                "Prone Y-T-W raises: 8 reps each"
            ],
            icon: "figure.open.water.swim",
            difficulty: "beginner",
            targets: ["shoulders"]
        ),

        // Breathing
        (
            name: "Posture Breathing Reset",
            category: "Breathing",
            description: "Use breath to release tension and improve alignment",
            duration: 5,
            steps: [
                "Diaphragmatic breathing: 2 minutes",
                "Crocodile breathing: 2 minutes (face down)",
                "90/90 breathing: 5 breaths with full exhale",
                "Standing tall breath scan: 1 minute"
            ],
            icon: "wind",
            difficulty: "beginner",
            targets: ["spine"]
        ),

        // Breaks
        (
            name: "Micro-Break (2 min)",
            category: "Breaks",
            description: "Quick reset you can do at your desk every hour",
            duration: 2,
            steps: [
                "Stand up and shake out limbs",
                "5 chin tucks",
                "5 shoulder rolls each direction",
                "Reach arms overhead and stretch",
                "Take 3 deep breaths"
            ],
            icon: "timer",
            difficulty: "beginner",
            targets: ["neck", "shoulders"]
        ),
        (
            name: "Eye & Neck Desk Break",
            category: "Breaks",
            description: "Relieve screen strain and neck tension",
            duration: 3,
            steps: [
                "20-20-20 rule: look 20 feet away for 20 seconds",
                "Close and rest eyes for 30 seconds",
                "Gentle neck stretches: 15 seconds each direction",
                "Shoulder shrugs: 10 reps",
                "Wrist circles: 10 each direction"
            ],
            icon: "eye",
            difficulty: "beginner",
            targets: ["neck"]
        )
    ]
}
