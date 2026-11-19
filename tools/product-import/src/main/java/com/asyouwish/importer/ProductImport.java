package com.asyouwish.importer;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

public final class ProductImport {
    private static final ObjectMapper JSON = new ObjectMapper();

    private ProductImport() {}

    public static void main(String[] args) throws Exception {
        Path input = args.length > 0 ? Path.of(args[0]) : Path.of("dummyjson-products-source.json");
        String output = args.length > 1 ? args[1] : "dummyjson-products.sql";
        JsonNode root = JSON.readTree(Files.readString(input, StandardCharsets.UTF_8));
        JsonNode productNodes = root.path("products");
        if (!productNodes.isArray()) throw new IOException("Input JSON must contain a products array");
        ArrayNode products = (ArrayNode) productNodes;
        Map<String, String> categories = new LinkedHashMap<>();
        Map<Integer, String> productCategories = new LinkedHashMap<>();

        for (JsonNode product : products) {
            String sourceCategory = text(product, "source_category");
            if (sourceCategory.isBlank()) throw new IOException("Missing stable source_category for product " + product.path("id"));
            String code = categoryCode(sourceCategory);
            categories.putIfAbsent(code, text(product, "category"));
            productCategories.put(product.path("id").asInt(), code);
        }

        StringBuilder sql = new StringBuilder(64_000);
        sql.append("-- DummyJSON 中文演示商品：价格数值沿用样例，不表示真实人民币定价。\nSET NAMES utf8mb4;\nSTART TRANSACTION;\n");
        appendCategories(sql, categories);
        appendMockWarehouse(sql);
        for (JsonNode product : products) {
            appendProduct(sql, product, productCategories.get(product.path("id").asInt()));
        }
        sql.append("COMMIT;\n");
        try (var writer = Files.newBufferedWriter(Path.of(output), StandardCharsets.UTF_8)) {
            for (int offset = 0; offset < sql.length(); offset += 4000) {
                writer.append(sql, offset, Math.min(offset + 4000, sql.length()));
            }
        }
        System.out.printf(Locale.ROOT, "Fetched %d products; SQL written to %s%n", products.size(), output);
    }

    private static void appendMockWarehouse(StringBuilder sql) {
        sql.append("INSERT INTO wms_warehouse (warehouse_code,name,status) VALUES ('DUMMYJSON-WH','DummyJSON 联调模拟仓',1) ")
                .append("ON DUPLICATE KEY UPDATE name=VALUES(name),status=1;\n")
                .append("SET @dummy_warehouse_id=(SELECT id FROM wms_warehouse WHERE warehouse_code='DUMMYJSON-WH');\n");
    }

    private static void appendCategories(StringBuilder sql, Map<String, String> categories) {
        sql.append("INSERT INTO gds_category (parent_id,category_code,name,level,sort_order,status) VALUES\n");
        int i = 0;
        for (Map.Entry<String, String> category : categories.entrySet()) {
            if (i++ > 0) sql.append(",\n");
            sql.append("(0,'").append(escape(category.getKey())).append("','")
                    .append(escape(limit(category.getValue(), 100)))
                    .append("',1,").append(i).append(",1)");
        }
        sql.append("\nON DUPLICATE KEY UPDATE name=VALUES(name),status=1;\n");
    }

    private static void appendProduct(StringBuilder sql, JsonNode product, String categoryCode) {
        int id = product.path("id").asInt();
        String title = text(product, "title");
        String description = text(product, "description");
        String brand = text(product, "brand");
        String spuCode = "DUMMY-SPU-" + id;
        String skuCode = "DUMMY-SKU-" + id;
        String image = text(product, "thumbnail");
        String categoryId = "(SELECT id FROM gds_category WHERE category_code='" + escape(categoryCode) + "')";

        sql.append("\n-- DummyJSON product ").append(id).append("\n")
           .append("INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES (")
           .append(categoryId).append(",'" ).append(escape(spuCode)).append("','")
           .append(escape(limit(title, 200))).append("','','").append(escape(limit(brand, 100))).append("','")
           .append(escape(limit(image, 512))).append("','").append(escape(description)).append("',1)\n")
           .append("ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;\n")
           .append("SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='").append(escape(spuCode)).append("');\n")
           .append("INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'")
           .append(escape(skuCode)).append("','").append(escape(limit(title, 200))).append("',JSON_OBJECT(),")
           .append(decimal(product.path("price"))).append(",NULL,NULL,1)\n")
           .append("ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;\n")
           .append("SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='").append(escape(skuCode)).append("');\n")
           .append("INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'")
           .append(escape(limit(image, 512))).append("',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='")
           .append(escape(limit(image, 512))).append("');\n")
            .append("INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,")
            .append(Math.max(0, product.path("stock").asInt(0))).append(",0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);\n")
            .append("INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) ")
            .append("SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-").append(id).append("',")
            .append(Math.max(0, product.path("stock").asInt(0))).append(',').append(Math.max(0, product.path("stock").asInt(0)))
            .append(",0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-")
            .append(id).append("' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);\n");
    }

    private static String text(JsonNode node, String field) {
        JsonNode value = node.path(field);
        return value.isMissingNode() || value.isNull() ? "" : value.asText();
    }

    private static String categoryCode(String source) {
        String slug = source.toLowerCase(Locale.ROOT).replaceAll("[^a-z0-9]+", "-").replaceAll("^-|-$", "");
        return "DUMMY-CAT-" + limit(slug, 48);
    }

    private static String decimal(JsonNode value) {
        return value.isNumber() ? value.decimalValue().setScale(2, java.math.RoundingMode.HALF_UP).toPlainString() : "0.00";
    }

    private static String escape(String value) {
        return value.replace("\\", "\\\\").replace("'", "''")
                .replace("\u0000", "").replace("\r", "\\r").replace("\n", "\\n");
    }

    private static String limit(String value, int max) {
        return value.length() <= max ? value : value.substring(0, max);
    }
}
