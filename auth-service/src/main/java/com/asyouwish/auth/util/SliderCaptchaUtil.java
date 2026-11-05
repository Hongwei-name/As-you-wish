package com.asyouwish.auth.util;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

/**
 * 滑块验证码工具类 (纯原生实现，无需额外依赖)
 */
public class SliderCaptchaUtil {

    private static final int WIDTH = 300;       // 画布宽度
    private static final int HEIGHT = 150;      // 画布高度
    private static final int SLIDER_WIDTH = 50; // 滑块宽度
    private static final int SLIDER_HEIGHT = 50;// 滑块高度

    /**
     * 生成滑块验证码
     * @return Map包含: bgBase64(背景图), sliderBase64(滑块图), x/y(滑块坐标)
     */
    public static Map<String, Object> createCaptcha() throws IOException {
        Map<String, Object> result = new HashMap<>();
        Random random = new Random();

        // 1. 创建底层背景图
        BufferedImage bgImage = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D bgGraphics = bgImage.createGraphics();

        // 画个好看的渐变色背景 (如果你有本地图片，可以用 ImageIO.read 替换)
        GradientPaint gradient = new GradientPaint(0, 0, new Color(200, 220, 255), WIDTH, HEIGHT, new Color(100, 150, 200));
        bgGraphics.setPaint(gradient);
        bgGraphics.fillRect(0, 0, WIDTH, HEIGHT);

        // 加点干扰线条，增加机器识别难度
        bgGraphics.setColor(Color.LIGHT_GRAY);
        for (int i = 0; i < 10; i++) {
            bgGraphics.drawLine(random.nextInt(WIDTH), random.nextInt(HEIGHT), random.nextInt(WIDTH), random.nextInt(HEIGHT));
        }
        bgGraphics.dispose();

        // 2. 创建滑块图
        BufferedImage sliderImage = new BufferedImage(SLIDER_WIDTH, SLIDER_HEIGHT, BufferedImage.TYPE_INT_ARGB);
        Graphics2D sliderGraphics = sliderImage.createGraphics();

        // 随机生成正确 X 坐标 (留出左右边距)
        // 因为前端滑块初始 X 通常是 0，所以正确答案范围一般在 50 到 WIDTH-SLIDER_WIDTH 之间
        int correctX = random.nextInt(WIDTH - SLIDER_WIDTH - 50) + 50;
        int correctY = random.nextInt(HEIGHT - SLIDER_HEIGHT - 20) + 10;

        // 从背景图中扣出滑块形状
        for (int i = 0; i < SLIDER_WIDTH; i++) {
            for (int j = 0; j < SLIDER_HEIGHT; j++) {
                // 抠图：把背景图的像素复制给滑块
                sliderImage.setRGB(i, j, bgImage.getRGB(correctX + i, correctY + j));
                // 在原图上画个缺口(半透明黑色阴影)
                bgImage.setRGB(correctX + i, correctY + j, new Color(0, 0, 0, 100).getRGB());
            }
        }

        // 给滑块加个白色边框，显得立体
        sliderGraphics.setColor(Color.WHITE);
        sliderGraphics.drawRect(0, 0, SLIDER_WIDTH - 1, SLIDER_HEIGHT - 1);
        sliderGraphics.dispose();

        // 3. 转成 Base64 方便前端展示
        result.put("bgBase64", "data:image/png;base64," + imageToBase64(bgImage));
        result.put("sliderBase64", "data:image/png;base64," + imageToBase64(sliderImage));
        result.put("x", correctX); // 返回 X 坐标给后端校验
        result.put("y", correctY); // 返回 Y 坐标供前端展示拼图位置

        return result;
    }

    /**
     * 将图片转为 Base64 字符串
     */
    private static String imageToBase64(BufferedImage image) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "png", baos);
        return Base64.getEncoder().encodeToString(baos.toByteArray());
    }
}