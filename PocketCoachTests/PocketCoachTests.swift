//
//  PocketCoachTests.swift
//  PocketCoachTests
//

import XCTest
@testable import PocketCoach

@MainActor
final class PocketCoachTests: XCTestCase {
    func test_angleType_definitionsAndSideRules() {
        XCTAssertEqual(PCAngleType.allCases.count, 9)

        XCTAssertEqual(PCAngleType.knee.definition, .threePoint(.hip, .knee, .ankle))
        XCTAssertEqual(PCAngleType.knee.sideRule, .bestConfidence)

        XCTAssertEqual(PCAngleType.hip.definition, .threePoint(.shoulder, .hip, .knee))
        XCTAssertEqual(PCAngleType.hip.sideRule, .bestConfidence)

        XCTAssertEqual(PCAngleType.elbow.definition, .threePoint(.shoulder, .elbow, .wrist))
        XCTAssertEqual(PCAngleType.elbow.sideRule, .bestConfidence)

        XCTAssertEqual(PCAngleType.bodyLine.definition, .threePoint(.shoulder, .hip, .ankle))
        XCTAssertEqual(PCAngleType.bodyLine.sideRule, .bestConfidence)

        XCTAssertEqual(PCAngleType.torsoLean.definition, .fromVertical(.hip, .shoulder))
        XCTAssertEqual(PCAngleType.torsoLean.sideRule, .bestConfidence)

        XCTAssertEqual(PCAngleType.frontKnee.definition, .threePoint(.hip, .knee, .ankle))
        XCTAssertEqual(PCAngleType.frontKnee.sideRule, .frontLeg)

        XCTAssertEqual(PCAngleType.rearKnee.definition, .threePoint(.hip, .knee, .ankle))
        XCTAssertEqual(PCAngleType.rearKnee.sideRule, .rearLeg)

        XCTAssertEqual(PCAngleType.hipSag.definition, .lineOffset(.shoulder, .hip, .ankle))
        XCTAssertEqual(PCAngleType.hipSag.sideRule, .bestConfidence)

        XCTAssertEqual(PCAngleType.upperArmLean.definition, .fromVertical(.elbow, .shoulder))
        XCTAssertEqual(PCAngleType.upperArmLean.sideRule, .bestConfidence)
    }

    func test_jointName_partAndSideMappings() {
        XCTAssertEqual(PCJointName.allCases.count, 17)
        XCTAssertEqual(PCJointName.joint(.shoulder, .left), .leftShoulder)
        XCTAssertEqual(PCJointName.joint(.shoulder, .right), .rightShoulder)
        XCTAssertEqual(PCJointName.joint(.elbow, .left), .leftElbow)
        XCTAssertEqual(PCJointName.joint(.elbow, .right), .rightElbow)
        XCTAssertEqual(PCJointName.joint(.wrist, .left), .leftWrist)
        XCTAssertEqual(PCJointName.joint(.wrist, .right), .rightWrist)
        XCTAssertEqual(PCJointName.joint(.hip, .left), .leftHip)
        XCTAssertEqual(PCJointName.joint(.hip, .right), .rightHip)
        XCTAssertEqual(PCJointName.joint(.knee, .left), .leftKnee)
        XCTAssertEqual(PCJointName.joint(.knee, .right), .rightKnee)
        XCTAssertEqual(PCJointName.joint(.ankle, .left), .leftAnkle)
        XCTAssertEqual(PCJointName.joint(.ankle, .right), .rightAnkle)
    }

    func test_exerciseTrackingMode_casesAndRawValues() {
        XCTAssertEqual(PCExerciseTrackingMode.allCases, [.reps, .hold])
        XCTAssertEqual(PCExerciseTrackingMode.reps.rawValue, "reps")
        XCTAssertEqual(PCExerciseTrackingMode.hold.rawValue, "hold")
    }

    func test_exerciseCatalog_attributes() {
        XCTAssertEqual(PCExercise.all.count, 4)
        let exercisesById = Dictionary(uniqueKeysWithValues: PCExercise.all.map { ($0.id, $0) })

        let squat = exercisesById["squat"]
        XCTAssertEqual(squat?.name, "Bodyweight Squats")
        XCTAssertEqual(squat?.cameraView, .side)
        XCTAssertEqual(squat?.trackingMode, .reps)
        XCTAssertEqual(squat?.targetAngles, [.knee, .hip, .torsoLean])

        let pushup = exercisesById["pushup"]
        XCTAssertEqual(pushup?.name, "Standard Push-ups")
        XCTAssertEqual(pushup?.cameraView, .side)
        XCTAssertEqual(pushup?.trackingMode, .reps)
        XCTAssertEqual(pushup?.targetAngles, [.elbow, .bodyLine, .hipSag])

        let lunge = exercisesById["lunge"]
        XCTAssertEqual(lunge?.name, "Forward Lunges")
        XCTAssertEqual(lunge?.cameraView, .side)
        XCTAssertEqual(lunge?.trackingMode, .reps)
        XCTAssertEqual(lunge?.targetAngles, [.frontKnee, .rearKnee, .hip, .torsoLean])

        let plank = exercisesById["plank"]
        XCTAssertEqual(plank?.name, "Forearm Plank")
        XCTAssertEqual(plank?.cameraView, .side)
        XCTAssertEqual(plank?.trackingMode, .hold)
        XCTAssertEqual(plank?.targetAngles, [.bodyLine, .hipSag, .knee, .upperArmLean])
    }
}
