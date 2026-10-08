package com.molham.modrenempire

import android.webkit.JavascriptInterface
import java.io.BufferedReader
import java.io.InputStreamReader
import java.net.Inet4Address
import java.net.InetSocketAddress
import java.net.NetworkInterface
import java.net.ServerSocket
import java.net.Socket
import java.util.Collections
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.ConcurrentLinkedQueue
import kotlin.concurrent.thread

/** Offline LAN transport for the game state protocol. It does not perform internet calls. */
class LanBridge {
    companion object { private const val PORT = 47777 }
    private var server: ServerSocket? = null
    private var socket: Socket? = null
    private val clients = ConcurrentHashMap.newKeySet<Socket>()
    private val queue = ConcurrentLinkedQueue<String>()
    @Volatile private var running = false
    @Volatile private var hosting = false

    @JavascriptInterface fun startHost(): String {
        if (running && hosting) return ip()
        stop(); hosting = true; running = true
        thread(name = "ModrenEmpire-LAN-Acceptor") {
            try {
                server = ServerSocket(PORT)
                while (running) {
                    val client = server!!.accept()
                    clients += client
                    thread(name = "ModrenEmpire-LAN-Client") { readLoop(client, true) }
                }
            } catch (_: Exception) { /* normal on stop */ }
        }
        return ip()
    }

    @JavascriptInterface fun connect(address: String): Boolean {
        stop(); hosting = false
        return try {
            val s = Socket()
            s.connect(InetSocketAddress(address.trim(), PORT), 3500)
            socket = s; running = true
            thread(name = "ModrenEmpire-LAN-Reader") { readLoop(s, false) }
            true
        } catch (_: Exception) { stop(); false }
    }

    @JavascriptInterface fun send(message: String) {
        val line = message.replace("\r", " ").replace("\n", " ") + "\n"
        val bytes = line.toByteArray(Charsets.UTF_8)
        try {
            if (hosting) clients.toList().forEach { client ->
                try { client.getOutputStream().write(bytes); client.getOutputStream().flush() }
                catch (_: Exception) { clients.remove(client); try { client.close() } catch (_: Exception) {} }
            } else socket?.let { it.getOutputStream().write(bytes); it.getOutputStream().flush() }
        } catch (_: Exception) { }
    }

    @JavascriptInterface fun poll(): String {
        val result = StringBuilder("["); var first = true
        while (true) {
            val item = queue.poll() ?: break
            if (!first) result.append(',')
            result.append(item.replace("\\", "\\\\").replace("\"", "\\\""))
            first = false
        }
        return result.append(']').toString()
    }

    @JavascriptInterface fun stop() {
        running = false
        try { server?.close() } catch (_: Exception) {}
        try { socket?.close() } catch (_: Exception) {}
        clients.toList().forEach { try { it.close() } catch (_: Exception) {} }
        clients.clear(); server = null; socket = null
    }

    @JavascriptInterface fun getIp(): String = ip()

    private fun readLoop(s: Socket, client: Boolean) {
        try {
            BufferedReader(InputStreamReader(s.getInputStream(), Charsets.UTF_8)).use { reader ->
                while (running) { val line = reader.readLine() ?: break; if (line.isNotBlank()) queue.add(line) }
            }
        } catch (_: Exception) { }
        finally { if (client) clients.remove(s); try { s.close() } catch (_: Exception) {} }
    }

    private fun ip(): String = try {
        Collections.list(NetworkInterface.getNetworkInterfaces()).asSequence()
            .flatMap { Collections.list(it.inetAddresses).asSequence() }
            .firstOrNull { !it.isLoopbackAddress && it is Inet4Address }?.hostAddress ?: "127.0.0.1"
    } catch (_: Exception) { "127.0.0.1" }
}
