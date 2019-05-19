package com.neonchipmunk.nfc

import android.Manifest
import android.app.Activity
import android.content.Context
import android.nfc.NfcAdapter
import android.nfc.NfcManager
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.os.Build
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.JSONMethodCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.IOException

const val PERMISSION_NFC = 1007

@Suppress("unused")
class NfcPlugin private constructor(registrar: Registrar, private val activity: Activity) : MethodCallHandler, EventChannel.StreamHandler, NfcAdapter.ReaderCallback {


    private val nfcManager: NfcManager? = registrar.activity().getSystemService(Context.NFC_SERVICE) as? NfcManager
    private val nfcAdapter: NfcAdapter? = nfcManager?.defaultAdapter
    private var eventSink: EventChannel.EventSink? = null

    companion object {
        @Suppress("unused")
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val methodChannel = MethodChannel(registrar.messenger(), "neonchipmunk.com/nfc", JSONMethodCodec.INSTANCE)
            val nfcPlugin = NfcPlugin(registrar, registrar.activity())
            methodChannel.setMethodCallHandler(nfcPlugin)
            val eventChannel = EventChannel(registrar.messenger(), "neonchipmunk.com/nfc/events", JSONMethodCodec.INSTANCE)
            eventChannel.setStreamHandler(nfcPlugin)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "start" -> {
                if (nfcAdapter == null) {
                    result.error("001", "NFC Hardware not found", null)
                    return
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    activity.requestPermissions(arrayOf(Manifest.permission.NFC), PERMISSION_NFC)
                }

                if (nfcAdapter.isEnabled && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    nfcAdapter.enableReaderMode(activity, this, NfcAdapter.FLAG_READER_NFC_A, null)
                    result.success(null)
                } else {
                    result.error("002", "NFC not supported", null)
                }
            }
            "stop" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    nfcAdapter?.disableReaderMode(activity)
                }
                eventSink?.endOfStream()
                result.success(null)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
        eventSink = p1
    }

    override fun onCancel(p0: Any?) {
        eventSink = null
    }

    override fun onTagDiscovered(tag: Tag?) {
        if (eventSink == null) return
        val ndef = Ndef.get(tag) ?: return
        try {
            ndef.connect()
            val message = ndef.ndefMessage ?: return
            val result = NdefTag(tag?.id, message.records.map {
                NdefRecord(it.tnf, it.type, it.id, it.payload)
            }.toList())
            ndef.close()
            println(result)
            eventSink?.success(result.toJson())
        } catch (e: IOException) {
            eventSink?.error("003", e.message, null)
        }

    }
}
