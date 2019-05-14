package com.neonchipmunk.nfc

import org.json.JSONArray
import org.json.JSONObject

class NdefTag(val id: String, val records : List<NdefRecord>) {
    fun toJson() :JSONObject{
        val jsonObject = JSONObject()
        jsonObject.put("id", id)
        val records = JSONArray()
        this.records.forEach {records.put(it.toJson())}
        jsonObject.put("records", records)
        return jsonObject
    }
}

class NdefRecord(val mimeType: String, val payload: String) {
    fun toJson() : JSONObject {
        return JSONObject()
        .put("mimeType", mimeType)
        .put("payload", payload)

    }
}