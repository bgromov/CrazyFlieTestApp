//
//  SimdExtensions.swift
//  CrazyFlieTestApp
//
//  Created by Boris Gromov on 15/08/2019.
//  Copyright © 2019 Volaly. All rights reserved.
//

import simd

public extension simd_double4x4 {
    init(_ m: simd_float4x4) {
        self.init(columns: (simd_double4(m.columns.0),
                            simd_double4(m.columns.1),
                            simd_double4(m.columns.2),
                            simd_double4(m.columns.3)))
    }
}

public extension simd_float4x4 {
    init(_ m: simd_double4x4) {
        self.init(columns: (simd_float4(m.columns.0),
                            simd_float4(m.columns.1),
                            simd_float4(m.columns.2),
                            simd_float4(m.columns.3)))
    }
}

public extension simd_double3x3 {
    /// Plain data in row-major order
    var rm_data: [Double] {
        return [columns.0[0], columns.1[0], columns.2[0],
                columns.0[1], columns.1[1], columns.2[1],
                columns.0[2], columns.1[2], columns.2[2]]
    }

    init(_ m: simd_float3x3) {
        self.init(columns: (simd_double3(m.columns.0),
                            simd_double3(m.columns.1),
                            simd_double3(m.columns.2)))
    }
}

public extension simd_float3x3 {
    /// Plain data in row-major order
    var rm_data: [Float] {
        return [columns.0[0], columns.1[0], columns.2[0],
                columns.0[1], columns.1[1], columns.2[1],
                columns.0[2], columns.1[2], columns.2[2]]
    }

    init(_ m: simd_double3x3) {
        self.init(columns: (simd_float3(m.columns.0),
                            simd_float3(m.columns.1),
                            simd_float3(m.columns.2)))
    }
}

public extension simd_quatd {
    /// The x-component of the imaginary (vector) part.
    var x: Double { return imag.x }
    /// The y-component of the imaginary (vector) part.
    var y: Double { return imag.y }
    /// The z-component of the imaginary (vector) part.
    var z: Double { return imag.z }
    /// The real (scalar) part.
    var w: Double { return real }

    var rpy: (Double, Double, Double) {
        get {
            let mat: simd_double3x3 = simd_double3x3(self)

            var yaw = Double.nan
            var pitch = Double.nan
            var roll = Double.nan

            pitch = atan2(-mat.rm_data[6], sqrt((mat.rm_data[0] * mat.rm_data[0] + mat.rm_data[3] * mat.rm_data[3])))

            if abs(pitch) > (Double.pi / 2 - Double.ulpOfOne) {
                yaw  = atan2(-mat.rm_data[1], mat.rm_data[4])
                roll = 0.0
            } else {
                roll = atan2(mat.rm_data[7], mat.rm_data[8])
                yaw  = atan2(mat.rm_data[3], mat.rm_data[0])
            }

            return (roll, pitch, yaw)
        }
    }

    init(roll: Double = 0.0, pitch: Double = 0.0, yaw: Double = 0.0) {
        let hy = yaw / 2.0
        let hp = pitch / 2.0
        let hr = roll / 2.0

        let cy = cos(hy)
        let sy = sin(hy)
        let cp = cos(hp)
        let sp = sin(hp)
        let cr = cos(hr)
        let sr = sin(hr)

        let quat: simd_double4 =
            simd_double4(x: sr * cp * cy - cr * sp * sy,
                         y: cr * sp * cy + sr * cp * sy,
                         z: cr * cp * sy - sr * sp * cy,
                         w: cr * cp * cy + sr * sp * sy)

        self.init(vector: quat)
    }
}

public extension simd_quatf {
    /// The x-component of the imaginary (vector) part.
    var x: Float { return imag.x }
    /// The y-component of the imaginary (vector) part.
    var y: Float { return imag.y }
    /// The z-component of the imaginary (vector) part.
    var z: Float { return imag.z }
    /// The real (scalar) part.
    var w: Float { return real }

    var rpy: (Float, Float, Float) {
        get {
            let mat: simd_float3x3 = simd_float3x3(self)

            var yaw = Float.nan
            var pitch = Float.nan
            var roll = Float.nan

            pitch = atan2(-mat.rm_data[6], sqrt((mat.rm_data[0] * mat.rm_data[0] + mat.rm_data[3] * mat.rm_data[3])))

            if abs(pitch) > (Float.pi / 2 - Float.ulpOfOne) {
                yaw  = atan2(-mat.rm_data[1], mat.rm_data[4])
                roll = 0.0
            } else {
                roll = atan2(mat.rm_data[7], mat.rm_data[8])
                yaw  = atan2(mat.rm_data[3], mat.rm_data[0])
            }

            return (roll, pitch, yaw)
        }
    }

    init(roll: Float = 0.0, pitch: Float = 0.0, yaw: Float = 0.0) {
        let hy = yaw / 2.0
        let hp = pitch / 2.0
        let hr = roll / 2.0

        let cy = cos(hy)
        let sy = sin(hy)
        let cp = cos(hp)
        let sp = sin(hp)
        let cr = cos(hr)
        let sr = sin(hr)

        let quat: simd_float4 =
            simd_float4(x: sr * cp * cy - cr * sp * sy,
                        y: cr * sp * cy + sr * cp * sy,
                        z: cr * cp * sy - sr * sp * cy,
                        w: cr * cp * cy + sr * sp * sy)

        self.init(vector: quat)
    }
}
