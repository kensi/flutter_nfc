package com.neonchipmunk.nfc

import android.Manifest
import android.app.Activity
import android.content.Context
import android.nfc.NfcAdapter
import android.nfc.NfcManager
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.os.Build
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException

const val PERMISSION_NFC = 1007

@Suppress("unused")
class NfcPlugin private constructor(registrar: Registrar, private val activity: Activity) : MethodCallHandler, NfcAdapter.ReaderCallback {
    private val nfcManager: NfcManager? = registrar.activity().getSystemService(Context.NFC_SERVICE) as? NfcManager
    private val nfcAdapter: NfcAdapter? = nfcManager?.defaultAdapter
    private var currentMethodCallResult: Result? = null

    companion object {
        @Suppress("unused")
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "neonchipmunk.com/nfc", JSONMethodCodec.INSTANCE)
            channel.setMethodCallHandler(NfcPlugin(registrar, registrar.activity()))
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "readSingleTag" -> {
                if (currentMethodCallResult != null) {
                    result.error("001", "Already processing", null)
                    return
                }
                if (nfcAdapter == null) {
                    result.error("002", "NFC Hardware not found", null)
                    return
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    activity.requestPermissions(arrayOf(Manifest.permission.NFC), PERMISSION_NFC)
                }

                if (nfcAdapter.isEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    currentMethodCallResult = result
                    nfcAdapter.enableReaderMode(activity, this, NfcAdapter.FLAG_READER_NFC_A, null)
                } else {
                    result.error("004", "NFC not supported", null)
                    currentMethodCallResult = null
                }
            }
            else -> {
                result.notImplemented()
            }

        }
    }

    override fun onTagDiscovered(tag: Tag?) {
        val ndef = Ndef.get(tag) ?: return
        try {
            ndef.connect()
            val message = ndef.ndefMessage ?: return
            val id = tag?.id?.joinToString(separator = "") { String.format("%02X", it) } ?: ""
            val result = NdefTag(id, message.records.map {
                NdefRecord(it.toMimeType() ?: "", it.payload.toString())
            }.toList())
            ndef.close()
            println(result.toString() + " " + result.records.size)
            currentMethodCallResult?.success(result.toJson())

        } catch (e : IOException) {
            currentMethodCallResult?.error("003", e.message, null)
        } finally {
            currentMethodCallResult = null
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            nfcAdapter?.disableReaderMode(activity)
        }
    }
}
