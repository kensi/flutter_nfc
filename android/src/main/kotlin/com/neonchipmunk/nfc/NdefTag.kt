package com.neonchipmunk.nfc

import org.json.JSONArray
import org.json.JSONObject
import java.util.*

class NdefTag(val id: ByteArray?, val records: List<NdefRecord>) {
    fun toJson(): JSONObject {
        val jsonObject = JSONObject()
        jsonObject.put("id", Base64.getEncoder().encodeToString(id))
        val records = JSONArray()
        this.records.forEach { records.put(it.toJson()) }
        jsonObject.put("records", records)
        return jsonObject
    }

    override fun toString(): String {
        return "NdefTag id=$id\n${records.joinToString(separator = "\n")}"
    }
}

class NdefRecord(val tnf: Short, val type: ByteArray, val id: ByteArray, val payload: ByteArray) {
    fun toJson(): JSONObject {
        return JSONObject()
                .put("tnf", tnf)
                .put("type", Base64.getEncoder().encodeToString(type))
                .put("id", Base64.getEncoder().encodeToString(id))
                .put("payload", Base64.getEncoder().encodeToString(payload))
    }

    override fun toString() : String {
        return "NdefRecord tnf=$tnf,type=${toHex(type)},id=${toHex(id)},${String(payload).trim()}"
    }
}

private fun toHex(data: ByteArray?) =
        data?.joinToString(separator = "") { String.format("%02X", it) } ?: ""