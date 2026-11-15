package com.asyouwish.auth.util;

import com.asyouwish.auth.config.MinioConfig;
import io.minio.BucketExistsArgs;
import io.minio.GetPresignedObjectUrlArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import io.minio.SetBucketPolicyArgs;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.util.Locale;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Slf4j
@Component
@RequiredArgsConstructor
public class MinioUtil {

    private static final String[] ALLOWED_SUFFIXES = {".jpg", ".jpeg", ".png", ".webp"};

    private final MinioClient minioClient;
    private final MinioConfig minioConfig;

    public String upload(MultipartFile file, String folder) {
        try {
            ensureBucket();
            String suffix = resolveSuffix(file.getOriginalFilename());
            String objectName = folder + "/" + UUID.randomUUID() + suffix;

            PutObjectArgs args = PutObjectArgs.builder()
                    .bucket(minioConfig.getBucketName())
                    .object(objectName)
                    .stream(file.getInputStream(), file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build();
            minioClient.putObject(args);
            log.info("Minio上传成功:{}", objectName);
            return objectName;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.error("Minio上传失败", e);
            throw new BusinessException("图片上传失败");
        }
    }

    public String getObjectUrl(String objectName) {
        String endpoint = minioConfig.getEndpoint();
        while (endpoint.endsWith("/")) {
            endpoint = endpoint.substring(0, endpoint.length() - 1);
        }
        return endpoint + "/" + minioConfig.getBucketName() + "/" + objectName;
    }

    /**
     * 获取私有桶临时签名url
     */
    public String getPresignedUrl(String objectName, int expireMinutes) {
        try {
            GetPresignedObjectUrlArgs args = GetPresignedObjectUrlArgs.builder()
                    .bucket(minioConfig.getBucketName())
                    .object(objectName)
                    .method(Method.GET)
                    .expiry(expireMinutes, TimeUnit.MINUTES)
                    .build();
            return minioClient.getPresignedObjectUrl(args);
        } catch (Exception e) {
            log.error("获取minio签名链接失败", e);
            throw new BusinessException("获取图片链接失败");
        }
    }

    /**
     * 删除文件
     */
    public void delete(String objectName) {
        try {
            RemoveObjectArgs args = RemoveObjectArgs.builder()
                    .bucket(minioConfig.getBucketName())
                    .object(objectName)
                    .build();
            minioClient.removeObject(args);
        } catch (Exception e) {
            log.error("删除文件失败", e);
        }
    }

    private String resolveSuffix(String originalName) {
        if (originalName == null) {
            throw new BusinessException("只允许 jpg / png / webp / jpeg 图片");
        }
        String lower = originalName.toLowerCase(Locale.ROOT);
        for (String suffix : ALLOWED_SUFFIXES) {
            if (lower.endsWith(suffix)) {
                return suffix;
            }
        }
        throw new BusinessException("只允许 jpg / png / webp / jpeg 图片");
    }

    private void ensureBucket() throws Exception {
        String bucket = minioConfig.getBucketName();
        boolean exists = minioClient.bucketExists(BucketExistsArgs.builder().bucket(bucket).build());
        if (!exists) {
            minioClient.makeBucket(MakeBucketArgs.builder().bucket(bucket).build());
            log.info("MinIO bucket 已创建: {}", bucket);
        }
        // 头像需要直接通过 URL 回显：每次上传都确保 bucket 对匿名用户只读。
        String policy = "{\"Version\":\"2012-10-17\",\"Statement\":[{\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"*\"]},\"Action\":[\"s3:GetObject\"],\"Resource\":[\"arn:aws:s3:::" + bucket + "/*\"]}]}";
        minioClient.setBucketPolicy(SetBucketPolicyArgs.builder().bucket(bucket).config(policy).build());
    }
}