package com.zerok.aiservice.util;

import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;

/**
 * 游标分页编码工具：把 (时间列, id) 编成不透明字符串，服务端原样回读。
 *
 * <p>时间列取库返回的原值，不作时区换算，保证 order by 比较前后一致。</p>
 */
public final class CursorUtil {

    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSS");

    private CursorUtil() {
    }

    public static String encode(LocalDateTime time, String id) {
        String raw = time.format(TIME_FORMATTER) + "|" + id;
        return Base64.getUrlEncoder().withoutPadding()
                .encodeToString(raw.getBytes(StandardCharsets.UTF_8));
    }

    public static Cursor decode(String cursor) {
        if (cursor == null || cursor.isBlank()) {
            return null;
        }
        try {
            String raw = new String(Base64.getUrlDecoder().decode(cursor), StandardCharsets.UTF_8);
            int separator = raw.lastIndexOf('|');
            if (separator < 0) {
                return null;
            }
            LocalDateTime time = LocalDateTime.parse(raw.substring(0, separator), TIME_FORMATTER);
            return new Cursor(time, raw.substring(separator + 1));
        } catch (RuntimeException e) {
            return null;
        }
    }

    public record Cursor(LocalDateTime time, String id) {
    }
}