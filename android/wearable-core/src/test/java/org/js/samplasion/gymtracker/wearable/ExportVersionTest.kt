package org.js.samplasion.gymtracker.wearable

import org.junit.Assert.*
import org.junit.Test

class ExportVersionTest {
    @Test fun crashAfterExternalWriteRetriesTheSameVersion() {
        val reserved = ExportVersion.reserve(null, null, "original")
        assertEquals(1, reserved.getInt("version"))
        assertEquals(1, ExportVersion.reserve(reserved, null, "original").getInt("version"))
    }
    @Test fun lateSensorDataAfterLostReceiptGetsANewerVersion() {
        val reserved = ExportVersion.reserve(null, null, "partial")
        val refined = ExportVersion.reserve(reserved, null, "final-samples")
        assertEquals(2, refined.getInt("version"))
        assertEquals(2, ExportVersion.reserve(refined, null, "final-samples").getInt("version"))
    }
}
