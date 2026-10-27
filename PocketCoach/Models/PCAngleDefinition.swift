//
//  PCAngleDefinition.swift
//  PocketCoach
//

/// Geometric definition describing how an anatomical measurement is computed from side-independent joint parts.
enum PCAngleDefinition: Equatable, Sendable {
    /// Interior angle in degrees measured at the middle joint part between segments extending to the first and third joint parts.
    case threePoint(PCJointPart, PCJointPart, PCJointPart)

    /// Angle in degrees of the segment from the first joint part to the second joint part measured against the vertical axis.
    case fromVertical(PCJointPart, PCJointPart)

    /// Signed perpendicular distance of the middle joint part from the line connecting the first and third joint parts,
    /// divided by the length of that line (unitless and body-size independent).
    ///
    /// Positive values indicate the middle joint is lower on screen than the reference line (e.g., hip sag),
    /// and negative values indicate it is higher on screen (e.g., hip pike), regardless of which way the person faces.
    /// Vision's normalized pose coordinates use a bottom-left origin (y-up), whereas screen coordinates use a top-left
    /// origin (y-down); the measurement engine converts to screen-space orientation (or negates the Vision y-axis)
    /// and uses the unsigned horizontal span or direction-normalized normal before computing the signed offset.
    case lineOffset(PCJointPart, PCJointPart, PCJointPart)
}
