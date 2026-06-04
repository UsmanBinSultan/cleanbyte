package com.example.sift

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.ContentValues
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.media.MediaScannerConnection
import android.os.Build
import android.os.BatteryManager
import android.os.Environment
import android.os.StatFs
import android.provider.MediaStore
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.util.UUID

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sift/apps")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInstalledApps" -> {
                        Thread {
                            try {
                                val apps = getInstalledApps()
                                runOnUiThread { result.success(apps) }
                            } catch (error: Exception) {
                                runOnUiThread {
                                    result.error(
                                        "apps_load_failed",
                                        error.message ?: "Android could not load installed apps.",
                                        null
                                    )
                                }
                            }
                        }.start()
                    }
                    "openUsageAccessSettings" -> {
                        startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sift/storage")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getStorageStats" -> result.success(getStorageStats())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sift/battery")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getBatteryStats" -> {
                        try {
                            result.success(getBatteryStats())
                        } catch (error: Exception) {
                            result.error(
                                "battery_read_failed",
                                error.message ?: "Android could not read battery details.",
                                null
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sift/photos")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openGallery" -> {
                        result.success(openGallery())
                    }
                    "compressImages" -> {
                        val photos = call.argument<List<Map<String, Any?>>>("photos") ?: emptyList()
                        val quality = call.argument<Int>("quality") ?: 60
                        try {
                            result.success(compressPhotos(photos, quality.coerceIn(1, 100)))
                        } catch (error: Exception) {
                            result.error(
                                "compression_failed",
                                error.message ?: "Android could not compress selected photos.",
                                null
                            )
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun getBatteryStats(): Map<String, Any?> {
        val intent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        val serviceLevel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            Int.MIN_VALUE
        }
        val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val percent = if (serviceLevel in 0..100) {
            serviceLevel
        } else if (level >= 0 && scale > 0) {
            (level * 100f / scale).toInt().coerceIn(0, 100)
        } else {
            0
        }
        val chargeCounterMicroAh = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
        } else {
            Int.MIN_VALUE
        }
        val estimatedCapacityMah = if (chargeCounterMicroAh > 0 && percent > 0) {
            (chargeCounterMicroAh / 1000.0) / (percent / 100.0)
        } else {
            null
        }
        val designCapacityMah = readBatteryCapacityMah() ?: readPowerProfileBatteryCapacityMah()
        val healthCode = intent?.getIntExtra(BatteryManager.EXTRA_HEALTH, 0) ?: 0
        val statusCode = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, 0) ?: 0
        val pluggedCode = intent?.getIntExtra(BatteryManager.EXTRA_PLUGGED, 0) ?: 0
        val temperatureTenths = intent?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, Int.MIN_VALUE)
            ?: Int.MIN_VALUE
        val voltage = intent?.getIntExtra(BatteryManager.EXTRA_VOLTAGE, 0) ?: 0

        return mapOf(
            "level" to percent,
            "capacityPercent" to percent,
            "designCapacityMah" to designCapacityMah,
            "estimatedCapacityMah" to estimatedCapacityMah,
            "health" to batteryHealthLabel(healthCode),
            "status" to batteryStatusLabel(statusCode),
            "isCharging" to (
                statusCode == BatteryManager.BATTERY_STATUS_CHARGING ||
                    statusCode == BatteryManager.BATTERY_STATUS_FULL ||
                    pluggedCode != 0
                ),
            "temperatureCelsius" to if (temperatureTenths == Int.MIN_VALUE) {
                null
            } else {
                temperatureTenths / 10.0
            },
            "voltage" to voltage
        )
    }

    private fun readBatteryCapacityMah(): Double? {
        val paths = listOf(
            "/sys/class/power_supply/battery/charge_full_design",
            "/sys/class/power_supply/battery/charge_full"
        )
        for (path in paths) {
            val value = try {
                File(path).takeIf { it.canRead() }?.readText()?.trim()?.toDoubleOrNull()
            } catch (_: Exception) {
                null
            } ?: continue
            if (value <= 0.0) {
                continue
            }
            return if (value > 10000.0) value / 1000.0 else value
        }
        return null
    }

    private fun readPowerProfileBatteryCapacityMah(): Double? {
        return try {
            val powerProfileClass = Class.forName("com.android.internal.os.PowerProfile")
            val constructor = powerProfileClass.getConstructor(Context::class.java)
            val powerProfile = constructor.newInstance(this)
            val method = powerProfileClass.getMethod("getBatteryCapacity")
            val value = (method.invoke(powerProfile) as? Number)?.toDouble()
            if (value != null && value in 1000.0..20000.0) value else null
        } catch (_: Exception) {
            null
        }
    }

    private fun batteryHealthLabel(code: Int): String {
        return when (code) {
            BatteryManager.BATTERY_HEALTH_GOOD -> "Good"
            BatteryManager.BATTERY_HEALTH_OVERHEAT -> "Overheat"
            BatteryManager.BATTERY_HEALTH_DEAD -> "Dead"
            BatteryManager.BATTERY_HEALTH_OVER_VOLTAGE -> "Over voltage"
            BatteryManager.BATTERY_HEALTH_UNSPECIFIED_FAILURE -> "Failure"
            BatteryManager.BATTERY_HEALTH_COLD -> "Cold"
            else -> "Unknown"
        }
    }

    private fun batteryStatusLabel(code: Int): String {
        return when (code) {
            BatteryManager.BATTERY_STATUS_CHARGING -> "Charging"
            BatteryManager.BATTERY_STATUS_DISCHARGING -> "Discharging"
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> "Not charging"
            BatteryManager.BATTERY_STATUS_FULL -> "Full"
            else -> "Unknown"
        }
    }

    private fun getStorageStats(): Map<String, Long> {
        val stat = StatFs(Environment.getDataDirectory().path)
        val totalBytes = marketedStorageBytes(stat.totalBytes)
        return mapOf(
            "totalBytes" to totalBytes,
            "freeBytes" to stat.availableBytes
        )
    }

    private fun marketedStorageBytes(usableBytes: Long): Long {
        val decimalGb = 1000L * 1000L * 1000L
        val commonSizes = longArrayOf(16, 32, 64, 128, 256, 512, 1024)
        for (size in commonSizes) {
            val advertised = size * decimalGb
            if (usableBytes <= advertised && usableBytes >= advertised * 70 / 100) {
                return advertised
            }
        }
        return usableBytes
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val launcherIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val usageAccess = hasUsageAccess()
        val usageByPackage = getUsageByPackage(usageAccess)
        val seenPackages = mutableSetOf<String>()

        return packageManager.queryIntentActivities(launcherIntent, 0)
            .mapNotNull { resolveInfo ->
                val appInfo = resolveInfo.activityInfo?.applicationInfo ?: return@mapNotNull null
                val appPackageName = appInfo.packageName
                if (
                    appPackageName == packageName ||
                    !seenPackages.add(appPackageName) ||
                    (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                ) {
                    return@mapNotNull null
                }

                val source = appInfo.sourceDir?.let { File(it) }
                mapOf(
                    "name" to resolveInfo.loadLabel(packageManager).toString(),
                    "packageName" to appPackageName,
                    "sizeBytes" to if (source?.exists() == true) source.length() else 0L,
                    "lastUsedMillis" to (usageByPackage[appPackageName] ?: 0L),
                    "hasUsageAccess" to usageAccess,
                    "iconBytes" to drawableToPngBytes(resolveInfo.loadIcon(packageManager))
                )
            }
            .sortedBy { (it["name"] as String).lowercase() }
            .toList()
    }

    private fun getUsageByPackage(hasAccess: Boolean): Map<String, Long> {
        if (!hasAccess) {
            return emptyMap()
        }

        return try {
            val usageStatsManager =
                getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val now = System.currentTimeMillis()
            val oneYearAgo = now - 365L * 24L * 60L * 60L * 1000L
            usageStatsManager
                .queryUsageStats(UsageStatsManager.INTERVAL_DAILY, oneYearAgo, now)
                .groupBy { it.packageName }
                .mapValues { entry -> entry.value.maxOf { it.lastTimeUsed } }
        } catch (_: Exception) {
            emptyMap()
        }
    }

    private fun hasUsageAccess(): Boolean {
        return try {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    packageName
                )
            } else {
                @Suppress("DEPRECATION")
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    android.os.Process.myUid(),
                    packageName
                )
            }
            mode == AppOpsManager.MODE_ALLOWED
        } catch (_: Exception) {
            false
        }
    }

    private fun drawableToPngBytes(drawable: Drawable): ByteArray {
        val width = drawable.intrinsicWidth.takeIf { it > 0 }?.coerceAtMost(72) ?: 72
        val height = drawable.intrinsicHeight.takeIf { it > 0 }?.coerceAtMost(72) ?: 72
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)

        return ByteArrayOutputStream().use { stream ->
            bitmap.compress(Bitmap.CompressFormat.PNG, 80, stream)
            bitmap.recycle()
            stream.toByteArray()
        }
    }

    private fun openGallery(): Boolean {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            type = "image/*"
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        if (intent.resolveActivity(packageManager) == null) {
            return false
        }
        startActivity(intent)
        return true
    }

    private fun compressPhotos(
        photos: List<Map<String, Any?>>,
        quality: Int
    ): List<Map<String, Any?>> {
        val outputDir = File(
            getExternalFilesDir(Environment.DIRECTORY_PICTURES),
            "compressed"
        ).apply { mkdirs() }

        return photos.mapNotNull { photo ->
            val id = photo["id"] as? String ?: return@mapNotNull null
            val name = photo["name"] as? String ?: "photo"
            val bytes = photo["bytes"] as? ByteArray ?: return@mapNotNull null
            val originalSize = (photo["originalSize"] as? Number)?.toLong() ?: bytes.size.toLong()

            val bounds = BitmapFactory.Options().apply { inJustDecodeBounds = true }
            BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
            val options = BitmapFactory.Options().apply {
                inSampleSize = calculateSampleSize(bounds, 2400, 2400)
            }
            val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)
                ?: return@mapNotNull null
            val output = File(outputDir, "clean_byte_${UUID.randomUUID()}.jpg")

            FileOutputStream(output).use { stream ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream)
            }
            bitmap.recycle()
            saveToGallery(output, name)

            mapOf(
                "id" to id,
                "name" to name,
                "outputPath" to output.absolutePath,
                "originalSize" to originalSize,
                "compressedSize" to output.length()
            )
        }
    }

    private fun saveToGallery(source: File, sourceName: String): String? {
        val baseName = sourceName
            .substringBeforeLast('.')
            .replace(Regex("[^A-Za-z0-9_-]"), "_")
            .ifBlank { "photo" }
        val fileName = "clean_byte_${baseName}_${UUID.randomUUID()}.jpg"

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/Clean Byte"
                )
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
            val uri = contentResolver.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                values
            ) ?: return null

            try {
                val outputStream = contentResolver.openOutputStream(uri)
                    ?: throw IllegalStateException("Could not open gallery output stream.")
                outputStream.use { output ->
                    source.inputStream().use { input -> input.copyTo(output) }
                }
                values.clear()
                values.put(MediaStore.Images.Media.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
                uri.toString()
            } catch (_: Exception) {
                contentResolver.delete(uri, null, null)
                null
            }
        } else {
            val directory = File(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES),
                "Clean Byte"
            ).apply { mkdirs() }
            val target = File(directory, fileName)
            try {
                source.copyTo(target, overwrite = true)
                MediaScannerConnection.scanFile(
                    this,
                    arrayOf(target.absolutePath),
                    arrayOf("image/jpeg"),
                    null
                )
                target.absolutePath
            } catch (_: Exception) {
                null
            }
        }
    }

    private fun calculateSampleSize(
        options: BitmapFactory.Options,
        reqWidth: Int,
        reqHeight: Int
    ): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            var halfHeight = height / 2
            var halfWidth = width / 2
            while (
                halfHeight / inSampleSize >= reqHeight &&
                halfWidth / inSampleSize >= reqWidth
            ) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }
}
