-- DummyJSON 中文演示商品：价格数值沿用样例，不表示真实人民币定价。
SET NAMES utf8mb4;
START TRANSACTION;
INSERT INTO gds_category (parent_id,category_code,name,level,sort_order,status) VALUES
(0,'DUMMY-CAT-beauty','美妆',1,1,1),
(0,'DUMMY-CAT-fragrances','香水',1,2,1),
(0,'DUMMY-CAT-furniture','家具',1,3,1),
(0,'DUMMY-CAT-groceries','杂货',1,4,1),
(0,'DUMMY-CAT-home-decoration','家居装饰',1,5,1),
(0,'DUMMY-CAT-kitchen-accessories','厨房配件',1,6,1),
(0,'DUMMY-CAT-laptops','笔记本电脑',1,7,1),
(0,'DUMMY-CAT-mens-shirts','男士衬衫',1,8,1),
(0,'DUMMY-CAT-mens-shoes','男鞋',1,9,1),
(0,'DUMMY-CAT-mens-watches','男士手表',1,10,1),
(0,'DUMMY-CAT-mobile-accessories','手机配件',1,11,1),
(0,'DUMMY-CAT-motorcycle','摩托车',1,12,1),
(0,'DUMMY-CAT-skin-care','个护',1,13,1),
(0,'DUMMY-CAT-smartphones','智能手机',1,14,1),
(0,'DUMMY-CAT-sports-accessories','运动配件',1,15,1),
(0,'DUMMY-CAT-sunglasses','太阳镜',1,16,1),
(0,'DUMMY-CAT-tablets','平板电脑',1,17,1),
(0,'DUMMY-CAT-tops','上装',1,18,1),
(0,'DUMMY-CAT-vehicle','汽车',1,19,1),
(0,'DUMMY-CAT-womens-bags','女包',1,20,1),
(0,'DUMMY-CAT-womens-dresses','女装连衣裙',1,21,1),
(0,'DUMMY-CAT-womens-jewellery','女士珠宝',1,22,1),
(0,'DUMMY-CAT-womens-shoes','女鞋',1,23,1),
(0,'DUMMY-CAT-womens-watches','女士腕表',1,24,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),status=1;
INSERT INTO wms_warehouse (warehouse_code,name,status) VALUES ('DUMMYJSON-WH','DummyJSON 联调模拟仓',1) ON DUPLICATE KEY UPDATE name=VALUES(name),status=1;
SET @dummy_warehouse_id=(SELECT id FROM wms_warehouse WHERE warehouse_code='DUMMYJSON-WH');

-- DummyJSON product 1
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-beauty'),'DUMMY-SPU-1','艾森丝睫毛公主浓密纤长睫毛膏','','艾森丝','https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp','艾森丝睫毛公主睫毛膏广受欢迎，以浓密和纤长效果著称。配方持久，且不进行动物测试，可打造醒目睫毛。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-1');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-1','艾森丝睫毛公主浓密纤长睫毛膏',JSON_OBJECT(),9.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-1');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/beauty/essence-mascara-lash-princess/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-1',99,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-1' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 2
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-beauty'),'DUMMY-SPU-2','带镜眼影盘','','魅丽彩妆','https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp','这款带镜眼影盘提供多种百搭色调，可打造出众眼妆。内置镜子，方便随时随地补妆。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-2');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-2','带镜眼影盘',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-2');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/beauty/eyeshadow-palette-with-mirror/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-2',34,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-2' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 3
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-beauty'),'DUMMY-SPU-3','散粉罐','','丝绒触感','https://cdn.dummyjson.com/product-images/beauty/powder-canister/thumbnail.webp','这款散粉经过细腻研磨，专为定妆和控油光设计。质地轻盈、妆感透明，可呈现平滑的哑光效果。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-3');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-3','散粉罐',JSON_OBJECT(),14.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-3');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/beauty/powder-canister/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/beauty/powder-canister/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,89,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-3',89,89,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-3' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 4
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-beauty'),'DUMMY-SPU-4','红色口红','','时尚彩妆','https://cdn.dummyjson.com/product-images/beauty/red-lipstick/thumbnail.webp','这款红色口红经典醒目，为双唇增添亮眼色彩。乳霜般顺滑且显色度高，妆效鲜艳持久。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-4');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-4','红色口红',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-4');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/beauty/red-lipstick/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/beauty/red-lipstick/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,91,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-4',91,91,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-4' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 5
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-beauty'),'DUMMY-SPU-5','红色指甲油','','美甲时装','https://cdn.dummyjson.com/product-images/beauty/red-nail-polish/thumbnail.webp','这款红色指甲油色泽浓郁亮泽，让指甲呈现鲜活精致的红色。速干配方，在家也能打造沙龙级美甲效果。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-5');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-5','红色指甲油',JSON_OBJECT(),8.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-5');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/beauty/red-nail-polish/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/beauty/red-nail-polish/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,79,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-5',79,79,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-5' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 6
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-fragrances'),'DUMMY-SPU-6','卡尔文·克雷恩 CK One 香水','','卡尔文·克雷恩','https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/thumbnail.webp','Calvin Klein CK One 是一款经典中性香氛，以清新洁净的气息闻名。香调百搭，适合日常使用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-6');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-6','卡尔文·克雷恩 CK One 香水',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-6');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/fragrances/calvin-klein-ck-one/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,29,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-6',29,29,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-6' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 7
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-fragrances'),'DUMMY-SPU-7','香奈儿可可 noir 香水','','香奈儿','https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/thumbnail.webp','香奈儿 Coco Noir 是一款优雅而神秘的香氛，带有葡萄柚、玫瑰和檀香气息，适合晚间场合。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-7');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-7','香奈儿可可 noir 香水',JSON_OBJECT(),129.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-7');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/fragrances/chanel-coco-noir-eau-de/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,58,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-7',58,58,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-7' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 8
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-fragrances'),'DUMMY-SPU-8','迪奥真我香水','','迪奥','https://cdn.dummyjson.com/product-images/fragrances/dior-j''adore/thumbnail.webp','迪奥真我是一款奢华的花香调香氛，以依兰、玫瑰和茉莉的融合香气著称，展现女性魅力与优雅气质。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-8');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-8','迪奥真我香水',JSON_OBJECT(),89.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-8');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/fragrances/dior-j''adore/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/fragrances/dior-j''adore/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,98,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-8',98,98,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-8' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 9
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-fragrances'),'DUMMY-SPU-9','杜嘉班纳 Dolce Shine 香水','','杜嘉班纳','https://cdn.dummyjson.com/product-images/fragrances/dolce-shine-eau-de/thumbnail.webp','杜嘉班纳 Dolce Shine 是一款活力四射的果香调香氛，带有芒果、茉莉和浅色木香气息，香调愉悦而充满青春气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-9');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-9','杜嘉班纳 Dolce Shine 香水',JSON_OBJECT(),69.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-9');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/fragrances/dolce-shine-eau-de/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/fragrances/dolce-shine-eau-de/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,4,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-9',4,4,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-9' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 10
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-fragrances'),'DUMMY-SPU-10','古驰 Bloom 香水','','古驰','https://cdn.dummyjson.com/product-images/fragrances/gucci-bloom-eau-de/thumbnail.webp','古驰 Bloom 是一款迷人的花香调香氛，带有晚香玉、茉莉和使君子藤的香气，气息现代而浪漫。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-10');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-10','古驰 Bloom 香水',JSON_OBJECT(),79.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-10');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/fragrances/gucci-bloom-eau-de/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/fragrances/gucci-bloom-eau-de/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,91,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-10',91,91,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-10' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 11
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-furniture'),'DUMMY-SPU-11','安尼巴莱·科伦坡床架','','安尼巴莱·科伦坡','https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/thumbnail.webp','安尼巴莱·科伦坡床架奢华优雅，采用优质材料打造，为卧室带来舒适又时尚的格调。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-11');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-11','安尼巴莱·科伦坡床架',JSON_OBJECT(),1899.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-11');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-bed/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-11',88,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-11' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 12
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-furniture'),'DUMMY-SPU-12','安尼巴莱·科伦坡沙发','','安尼巴莱·科伦坡','https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-sofa/thumbnail.webp','安尼巴莱·科伦坡沙发兼具精致设计与舒适坐感，搭配高档面料，是客厅的优雅之选。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-12');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-12','安尼巴莱·科伦坡沙发',JSON_OBJECT(),2499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-12');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-sofa/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/furniture/annibale-colombo-sofa/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,60,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-12',60,60,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-12' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 13
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-furniture'),'DUMMY-SPU-13','非洲樱桃木床头柜','','家具公司','https://cdn.dummyjson.com/product-images/furniture/bedside-table-african-cherry/thumbnail.webp','这款非洲樱桃木床头柜时尚实用，为卧室提供便捷取物的收纳空间，并增添一份优雅气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-13');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-13','非洲樱桃木床头柜',JSON_OBJECT(),299.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-13');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/furniture/bedside-table-african-cherry/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/furniture/bedside-table-african-cherry/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,64,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-13',64,64,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-13' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 14
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-furniture'),'DUMMY-SPU-14','诺尔·萨里宁行政会议椅','','诺尔','https://cdn.dummyjson.com/product-images/furniture/knoll-saarinen-executive-conference-chair/thumbnail.webp','诺尔·萨里宁行政会议椅设计现代且符合人体工学，造型历久弥新，非常适合办公室或会议室。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-14');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-14','诺尔·萨里宁行政会议椅',JSON_OBJECT(),499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-14');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/furniture/knoll-saarinen-executive-conference-chair/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/furniture/knoll-saarinen-executive-conference-chair/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,26,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-14',26,26,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-14' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 15
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-furniture'),'DUMMY-SPU-15','木质浴室洗手台（带镜子）','','浴室潮流','https://cdn.dummyjson.com/product-images/furniture/wooden-bathroom-sink-with-mirror/thumbnail.webp','这款木质浴室洗手台别具一格、时尚大方，配有木质台面和相配的镜子，为浴室增添独特风格。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-15');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-15','木质浴室洗手台（带镜子）',JSON_OBJECT(),799.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-15');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/furniture/wooden-bathroom-sink-with-mirror/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/furniture/wooden-bathroom-sink-with-mirror/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-15',7,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-15' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 16
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-16','苹果','','','https://cdn.dummyjson.com/product-images/groceries/apple/thumbnail.webp','新鲜爽脆的苹果，适合直接食用，也可用于制作各种菜肴和点心。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-16');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-16','苹果',JSON_OBJECT(),1.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-16');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/apple/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/apple/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,8,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-16',8,8,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-16' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 17
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-17','牛排','','','https://cdn.dummyjson.com/product-images/groceries/beef-steak/thumbnail.webp','优质牛排，适合烧烤或按您喜欢的熟度烹调。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-17');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-17','牛排',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-17');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/beef-steak/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/beef-steak/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-17',86,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-17' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 18
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-18','猫粮','','','https://cdn.dummyjson.com/product-images/groceries/cat-food/thumbnail.webp','营养丰富的猫粮，配方旨在满足爱猫的膳食营养需求。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-18');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-18','猫粮',JSON_OBJECT(),8.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-18');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/cat-food/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/cat-food/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,46,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-18',46,46,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-18' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 19
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-19','鸡肉','','','https://cdn.dummyjson.com/product-images/groceries/chicken-meat/thumbnail.webp','新鲜鲜嫩的鸡肉，适用于多种烹饪方式。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-19');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-19','鸡肉',JSON_OBJECT(),9.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-19');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/chicken-meat/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/chicken-meat/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,97,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-19',97,97,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-19' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 20
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-20','食用油','','','https://cdn.dummyjson.com/product-images/groceries/cooking-oil/thumbnail.webp','用途广泛的食用油，适合油炸、煎炒及各种烹饪用途。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-20');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-20','食用油',JSON_OBJECT(),4.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-20');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/cooking-oil/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/cooking-oil/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,10,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-20',10,10,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-20' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 21
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-21','黄瓜','','','https://cdn.dummyjson.com/product-images/groceries/cucumber/thumbnail.webp','爽脆多汁的黄瓜，适合做沙拉、当零食，也可作为清爽的配菜。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-21');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-21','黄瓜',JSON_OBJECT(),1.49,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-21');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/cucumber/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/cucumber/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-21',84,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-21' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 22
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-22','狗粮','','','https://cdn.dummyjson.com/product-images/groceries/dog-food/thumbnail.webp','专门调配的狗粮，旨在为您的爱犬提供必需营养。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-22');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-22','狗粮',JSON_OBJECT(),10.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-22');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/dog-food/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/dog-food/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,71,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-22',71,71,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-22' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 23
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-23','鸡蛋','','','https://cdn.dummyjson.com/product-images/groceries/eggs/thumbnail.webp','新鲜鸡蛋，是烘焙、烹饪或制作早餐的百搭食材。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-23');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-23','鸡蛋',JSON_OBJECT(),2.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-23');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/eggs/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/eggs/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,9,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-23',9,9,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-23' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 24
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-24','鱼排','','','https://cdn.dummyjson.com/product-images/groceries/fish-steak/thumbnail.webp','优质鱼排，适合烧烤、烘烤或平底锅煎制。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-24');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-24','鱼排',JSON_OBJECT(),14.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-24');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/fish-steak/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/fish-steak/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,74,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-24',74,74,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-24' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 25
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-25','青甜椒','','','https://cdn.dummyjson.com/product-images/groceries/green-bell-pepper/thumbnail.webp','新鲜鲜亮的青甜椒，能为菜肴增添色彩与风味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-25');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-25','青甜椒',JSON_OBJECT(),1.29,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-25');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/green-bell-pepper/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/green-bell-pepper/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,33,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-25',33,33,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-25' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 26
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-26','青辣椒','','','https://cdn.dummyjson.com/product-images/groceries/green-chili-pepper/thumbnail.webp','辛辣的青辣椒，适合为您喜爱的食谱增添辣味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-26');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-26','青辣椒',JSON_OBJECT(),0.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-26');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/green-chili-pepper/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/green-chili-pepper/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,3,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-26',3,3,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-26' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 27
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-27','蜂蜜罐','','','https://cdn.dummyjson.com/product-images/groceries/honey-jar/thumbnail.webp','纯天然蜂蜜，装在方便取用的罐中，适合为饮品调甜或淋在食物上。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-27');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-27','蜂蜜罐',JSON_OBJECT(),6.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-27');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/honey-jar/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/honey-jar/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-27',34,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-27' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 28
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-28','冰淇淋','','','https://cdn.dummyjson.com/product-images/groceries/ice-cream/thumbnail.webp','口感醇厚、美味可口的冰淇淋，提供多种口味，是令人愉悦的甜品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-28');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-28','冰淇淋',JSON_OBJECT(),5.49,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-28');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/ice-cream/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/ice-cream/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-28',27,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-28' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 29
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-29','果汁','','','https://cdn.dummyjson.com/product-images/groceries/juice/thumbnail.webp','清爽的果汁富含维生素，有助于补充水分。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-29');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-29','果汁',JSON_OBJECT(),3.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-29');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/juice/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/juice/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,50,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-29',50,50,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-29' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 30
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-30','猕猴桃','','','https://cdn.dummyjson.com/product-images/groceries/kiwi/thumbnail.webp','营养丰富的猕猴桃，适合当零食，也能为菜肴增添热带风味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-30');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-30','猕猴桃',JSON_OBJECT(),2.49,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-30');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/kiwi/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/kiwi/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-30',99,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-30' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 31
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-31','柠檬','','','https://cdn.dummyjson.com/product-images/groceries/lemon/thumbnail.webp','酸香清爽的柠檬用途广泛，可用于烹饪、烘焙或制作清凉饮品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-31');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-31','柠檬',JSON_OBJECT(),0.79,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-31');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/lemon/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/lemon/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,31,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-31',31,31,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-31' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 32
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-32','牛奶','','','https://cdn.dummyjson.com/product-images/groceries/milk/thumbnail.webp','新鲜营养的牛奶，是多种食谱和日常饮用的常备食品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-32');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-32','牛奶',JSON_OBJECT(),3.49,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-32');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/milk/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/milk/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-32',27,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-32' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 33
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-33','桑葚','','','https://cdn.dummyjson.com/product-images/groceries/mulberry/thumbnail.webp','香甜多汁的桑葚，适合直接食用，也可加入甜点和谷物中。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-33');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-33','桑葚',JSON_OBJECT(),4.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-33');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/mulberry/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/mulberry/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-33',99,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-33' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 34
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-34','雀巢咖啡','','','https://cdn.dummyjson.com/product-images/groceries/nescafe-coffee/thumbnail.webp','雀巢提供的优质咖啡，有多种拼配可选，带来浓郁而令人满足的一杯。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-34');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-34','雀巢咖啡',JSON_OBJECT(),7.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-34');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/nescafe-coffee/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/nescafe-coffee/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,57,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-34',57,57,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-34' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 35
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-35','土豆','','','https://cdn.dummyjson.com/product-images/groceries/potatoes/thumbnail.webp','用途广泛、淀粉含量丰富的土豆，适合烤制、捣成泥或作为配菜。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-35');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-35','土豆',JSON_OBJECT(),2.29,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-35');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/potatoes/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/potatoes/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,13,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-35',13,13,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-35' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 36
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-36','蛋白粉','','','https://cdn.dummyjson.com/product-images/groceries/protein-powder/thumbnail.webp','营养丰富的蛋白粉，适合用来补充饮食所需的优质蛋白质。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-36');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-36','蛋白粉',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-36');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/protein-powder/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/protein-powder/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,80,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-36',80,80,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-36' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 37
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-37','红洋葱','','','https://cdn.dummyjson.com/product-images/groceries/red-onions/thumbnail.webp','香味浓郁的红洋葱，适合为咸味菜肴增添层次和风味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-37');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-37','红洋葱',JSON_OBJECT(),1.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-37');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/red-onions/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/red-onions/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-37',82,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-37' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 38
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-38','大米','','','https://cdn.dummyjson.com/product-images/groceries/rice/thumbnail.webp','优质大米是多种菜系的主食，也可作为许多菜肴的百搭基础。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-38');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-38','大米',JSON_OBJECT(),5.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-38');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/rice/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/rice/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-38',59,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-38' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 39
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-39','软饮料','','','https://cdn.dummyjson.com/product-images/groceries/soft-drinks/thumbnail.webp','多种口味的混合装软饮料，适合随时畅饮解渴。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-39');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-39','软饮料',JSON_OBJECT(),1.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-39');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/soft-drinks/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/soft-drinks/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-39',53,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-39' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 40
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-40','草莓','','','https://cdn.dummyjson.com/product-images/groceries/strawberry/thumbnail.webp','香甜多汁的草莓，适合直接食用、制作甜点或打成果昔。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-40');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-40','草莓',JSON_OBJECT(),3.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-40');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/strawberry/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/strawberry/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,46,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-40',46,46,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-40' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 41
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-41','盒装纸巾','','','https://cdn.dummyjson.com/product-images/groceries/tissue-paper-box/thumbnail.webp','方便实用的盒装纸巾，适合日常使用，纸巾柔软且吸水性好。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-41');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-41','盒装纸巾',JSON_OBJECT(),2.49,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-41');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/tissue-paper-box/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/tissue-paper-box/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-41',86,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-41' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 42
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-groceries'),'DUMMY-SPU-42','瓶装水','','','https://cdn.dummyjson.com/product-images/groceries/water/thumbnail.webp','纯净清爽的瓶装水，是全天保持水分充足的必需品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-42');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-42','瓶装水',JSON_OBJECT(),0.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-42');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/groceries/water/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/groceries/water/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-42',53,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-42' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 43
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-home-decoration'),'DUMMY-SPU-43','装饰秋千','','','https://cdn.dummyjson.com/product-images/home-decoration/decoration-swing/thumbnail.webp','这款装饰秋千为家居增添迷人点缀。精致细节赋予房间优雅气息与一丝趣味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-43');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-43','装饰秋千',JSON_OBJECT(),59.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-43');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/home-decoration/decoration-swing/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/home-decoration/decoration-swing/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,47,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-43',47,47,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-43' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 44
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-home-decoration'),'DUMMY-SPU-44','家族树相框','','','https://cdn.dummyjson.com/product-images/home-decoration/family-tree-photo-frame/thumbnail.webp','这款家族树相框以温馨又时尚的方式展示珍贵的家庭回忆。多个照片位串联起亲友的故事。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-44');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-44','家族树相框',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-44');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/home-decoration/family-tree-photo-frame/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/home-decoration/family-tree-photo-frame/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,77,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-44',77,77,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-44' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 45
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-home-decoration'),'DUMMY-SPU-45','家居仿真观赏植物','','','https://cdn.dummyjson.com/product-images/home-decoration/house-showpiece-plant/thumbnail.webp','这款家居观赏植物为仿真植物，无需养护也能为家中带来自然气息。它为任何空间增添绿意与格调。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-45');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-45','家居仿真观赏植物',JSON_OBJECT(),39.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-45');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/home-decoration/house-showpiece-plant/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/home-decoration/house-showpiece-plant/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,28,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-45',28,28,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-45' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 46
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-home-decoration'),'DUMMY-SPU-46','花盆','','','https://cdn.dummyjson.com/product-images/home-decoration/plant-pot/thumbnail.webp','这款花盆时尚雅致，可用于摆放心爱的植物。简洁流畅的设计与室内或室外花园相得益彰，为植物陈列增添现代感。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-46');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-46','花盆',JSON_OBJECT(),14.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-46');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/home-decoration/plant-pot/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/home-decoration/plant-pot/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-46',59,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-46' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 47
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-home-decoration'),'DUMMY-SPU-47','台灯','','','https://cdn.dummyjson.com/product-images/home-decoration/table-lamp/thumbnail.webp','这款台灯兼具实用照明与装饰功能，适合起居空间。现代设计同时提供环境照明和工作照明，提升空间氛围。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-47');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-47','台灯',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-47');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/home-decoration/table-lamp/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/home-decoration/table-lamp/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,9,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-47',9,9,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-47' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 48
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-48','竹锅铲','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/bamboo-spatula/thumbnail.webp','这款竹锅铲采用环保竹材制成，是用途多样的厨房工具，适合翻面、搅拌和盛取各种菜肴。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-48');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-48','竹锅铲',JSON_OBJECT(),7.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-48');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/bamboo-spatula/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/bamboo-spatula/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,37,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-48',37,37,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-48' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 49
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-49','黑色铝制杯','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/black-aluminium-cup/thumbnail.webp','这款黑色铝制杯时尚耐用，冷热饮品皆宜。简洁利落的黑色外观为您的饮具增添现代气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-49');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-49','黑色铝制杯',JSON_OBJECT(),5.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-49');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/black-aluminium-cup/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/black-aluminium-cup/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-49',75,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-49' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 50
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-50','黑色打蛋器','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/black-whisk/thumbnail.webp','这款黑色打蛋器是厨房必备工具，适合搅打和打发食材。符合人体工学的手柄与简洁设计兼具实用性和美观度。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-50');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-50','黑色打蛋器',JSON_OBJECT(),9.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-50');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/black-whisk/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/black-whisk/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,73,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-50',73,73,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-50' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 51
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-51','盒装搅拌机','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/boxed-blender/thumbnail.webp','这款盒装搅拌机动力强劲、机身紧凑，非常适合制作冰沙、奶昔等饮品。设计便捷且功能多样，是一款用途广泛的厨房电器。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-51');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-51','盒装搅拌机',JSON_OBJECT(),39.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-51');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/boxed-blender/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/boxed-blender/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,9,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-51',9,9,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-51' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 52
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-52','碳钢炒锅','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/carbon-steel-wok/thumbnail.webp','这款碳钢炒锅用途多样，适合爆炒、煎炒和油炸。坚固的锅体有助于均匀导热，轻松烹制美味佳肴。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-52');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-52','碳钢炒锅',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-52');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/carbon-steel-wok/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/carbon-steel-wok/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-52',40,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-52' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 53
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-53','砧板','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/chopping-board/thumbnail.webp','砧板是备餐时必不可少的厨房用品。它采用耐用材质制成，为切割和剁切食材提供安全、卫生的操作表面。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-53');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-53','砧板',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-53');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/chopping-board/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/chopping-board/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,14,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-53',14,14,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-53' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 54
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-54','黄色柑橘榨汁器','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/citrus-squeezer-yellow/thumbnail.webp','这款黄色柑橘榨汁器可轻松榨取柑橘类水果的汁液。鲜亮的颜色也为厨房小工具增添一抹欢快气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-54');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-54','黄色柑橘榨汁器',JSON_OBJECT(),8.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-54');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/citrus-squeezer-yellow/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/citrus-squeezer-yellow/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,22,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-54',22,22,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-54' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 55
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-55','鸡蛋切片器','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/egg-slicer/thumbnail.webp','这款鸡蛋切片器方便将煮熟的鸡蛋切成均匀薄片，适合制作沙拉、三明治，以及其他需要鸡蛋片的菜肴。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-55');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-55','鸡蛋切片器',JSON_OBJECT(),6.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-55');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/egg-slicer/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/egg-slicer/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-55',40,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-55' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 56
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-56','电炉','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/electric-stove/thumbnail.webp','这款电炉提供便携且高效的烹饪方式，适合小型厨房使用，也可作为额外的烹饪炉面，满足各种烹饪需求。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-56');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-56','电炉',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-56');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/electric-stove/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/electric-stove/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,21,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-56',21,21,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-56' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 57
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-57','细网滤网','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/fine-mesh-strainer/thumbnail.webp','这款细网滤网用途多样，既可过滤液体，也可筛分干燥食材。细密网面能有效滤除杂质，让烹饪和烘焙成品更加细腻。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-57');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-57','细网滤网',JSON_OBJECT(),9.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-57');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/fine-mesh-strainer/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/fine-mesh-strainer/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,85,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-57',85,85,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-57' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 58
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-58','叉子','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/fork/thumbnail.webp','这款叉子是经典餐具，适用于多种用餐和上菜场景。耐用且符合人体工学的设计，让它成为可靠的日常用品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-58');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-58','叉子',JSON_OBJECT(),3.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-58');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/fork/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/fork/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-58',7,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-58' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 59
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-59','玻璃杯','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/glass/thumbnail.webp','这款玻璃杯兼具多用途与优雅外观，适合盛装各种饮品。通透的杯身让饮品的色彩与质感一览无余。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-59');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-59','玻璃杯',JSON_OBJECT(),4.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-59');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/glass/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/glass/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,46,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-59',46,46,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-59' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 60
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-60','黑色刨丝器','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/grater-black/thumbnail.webp','这款黑色刨丝器是实用的厨房工具，可用于刨碎奶酪、蔬菜等食材。简洁利落的外观搭配锋利刀片，让备餐更高效轻松。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-60');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-60','黑色刨丝器',JSON_OBJECT(),10.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-60');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/grater-black/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/grater-black/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-60',84,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-60' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 61
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-61','手持搅拌机','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/hand-blender/thumbnail.webp','这款手持搅拌机用途广泛，可用于搅拌、打成泥和混合食材。机身紧凑且电机动力强劲，是制作各种食谱时方便实用的工具。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-61');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-61','手持搅拌机',JSON_OBJECT(),34.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-61');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/hand-blender/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/hand-blender/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-61',84,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-61' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 62
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-62','冰格','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/ice-cube-tray/thumbnail.webp','这款冰格是制作不同形状冰块的实用配件，既能为饮品降温，也能为饮料增添趣味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-62');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-62','冰格',JSON_OBJECT(),5.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-62');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/ice-cube-tray/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/ice-cube-tray/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,13,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-62',13,13,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-62' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 63
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-63','厨房筛网','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/kitchen-sieve/thumbnail.webp','这款厨房筛网用途多样，可筛分或过滤干、湿食材。细密网面有助于烹饪和烘焙获得细腻顺滑的效果。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-63');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-63','厨房筛网',JSON_OBJECT(),7.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-63');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/kitchen-sieve/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/kitchen-sieve/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,68,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-63',68,68,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-63' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 64
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-64','厨房刀','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/knife/thumbnail.webp','这把刀是厨房必备工具，可用于剁切、切片和切丁。锋利的刀刃与符合人体工学的手柄，使其成为可靠的备餐利器。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-64');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-64','厨房刀',JSON_OBJECT(),14.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-64');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/knife/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/knife/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-64',7,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-64' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 65
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-65','便当盒','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/lunch-box/thumbnail.webp','这款便当盒方便携带，可用于分装和携带餐食。内部设有多个分隔区域，便于分别存放不同食物，非常适合外出用餐。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-65');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-65','便当盒',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-65');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/lunch-box/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/lunch-box/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,94,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-65',94,94,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-65' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 66
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-66','微波炉','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/microwave-oven/thumbnail.webp','这款微波炉用途广泛，可快速高效地烹饪、加热和解冻食物。紧凑的尺寸适合多种厨房布局。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-66');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-66','微波炉',JSON_OBJECT(),89.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-66');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/microwave-oven/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/microwave-oven/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-66',59,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-66' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 67
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-67','马克杯树形架','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/mug-tree-stand/thumbnail.webp','这款马克杯树形架外观时尚且节省空间，能帮助整理马克杯，让常用杯子在厨房中摆放整齐、取用方便。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-67');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-67','马克杯树形架',JSON_OBJECT(),15.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-67');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/mug-tree-stand/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/mug-tree-stand/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-67',88,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-67' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 68
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-68','煎锅','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/pan/thumbnail.webp','这款煎锅用途广泛，是厨房必备炊具，适合煎、炒及烹制各种菜肴。不粘涂层让食物更易脱离锅面，清洁也更轻松。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-68');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-68','煎锅',JSON_OBJECT(),24.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-68');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/pan/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/pan/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-68',90,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-68' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 69
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-69','餐盘','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/plate/thumbnail.webp','这款餐盘是经典且必备的餐具，适合盛放餐食。设计耐用又美观，既适合日常使用，也适用于特别场合。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-69');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-69','餐盘',JSON_OBJECT(),3.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-69');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/plate/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/plate/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,66,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-69',66,66,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-69' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 70
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-70','红色厨房夹','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/red-tongs/thumbnail.webp','这款红色厨房夹用途多样，适用于各种烹饪和上菜操作。鲜亮的颜色为厨房用具增添活力。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-70');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-70','红色厨房夹',JSON_OBJECT(),6.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-70');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/red-tongs/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/red-tongs/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-70',82,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-70' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 71
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-71','银色玻璃盖汤锅','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/silver-pot-with-glass-cap/thumbnail.webp','这款银色汤锅兼具时尚外观与实用性，适合煮沸、慢炖并烹制美味餐食。玻璃锅盖便于随时观察烹饪进度。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-71');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-71','银色玻璃盖汤锅',JSON_OBJECT(),39.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-71');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/silver-pot-with-glass-cap/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/silver-pot-with-glass-cap/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-71',40,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-71' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 72
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-72','漏孔锅铲','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/slotted-turner/thumbnail.webp','这款漏孔锅铲专为翻动食物设计。带孔结构可沥走多余液体，因此特别适合煎炸和煎炒。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-72');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-72','漏孔锅铲',JSON_OBJECT(),8.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-72');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/slotted-turner/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/slotted-turner/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-72',88,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-72' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 73
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-73','香料架','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/spice-rack/thumbnail.webp','这款香料架可方便地收纳各种香料和调味料，让厨房必备调料摆放整齐、触手可及，同时为厨房增添时尚气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-73');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-73','香料架',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-73');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/spice-rack/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/spice-rack/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,79,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-73',79,79,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-73' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 74
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-74','勺子','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/spoon/thumbnail.webp','这款勺子用途多样，可用于搅拌、盛取和品尝食物。符合人体工学的设计与耐用结构，使其成为每个厨房的必备工具。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-74');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-74','勺子',JSON_OBJECT(),4.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-74');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/spoon/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/spoon/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-74',59,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-74' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 75
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-75','托盘','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/tray/thumbnail.webp','这款托盘兼具实用与装饰功能，可用于盛放零食、开胃小点或饮品。时尚的设计使其成为招待客人时用途多样的配件。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-75');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-75','托盘',JSON_OBJECT(),16.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-75');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/tray/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/tray/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,71,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-75',71,71,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-75' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 76
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-76','木制擀面杖','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/wooden-rolling-pin/thumbnail.webp','这款木制擀面杖是经典厨房工具，可用于擀开烘焙面团。光滑的表面和结实的手柄便于操作，能将面团擀得厚薄均匀。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-76');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-76','木制擀面杖',JSON_OBJECT(),11.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-76');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/wooden-rolling-pin/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/wooden-rolling-pin/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,80,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-76',80,80,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-76' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 77
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-kitchen-accessories'),'DUMMY-SPU-77','黄色削皮器','','','https://cdn.dummyjson.com/product-images/kitchen-accessories/yellow-peeler/thumbnail.webp','这款黄色削皮器可轻松为水果和蔬菜去皮。明亮的黄色为厨房小工具增添欢快气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-77');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-77','黄色削皮器',JSON_OBJECT(),5.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-77');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/kitchen-accessories/yellow-peeler/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/kitchen-accessories/yellow-peeler/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,35,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-77',35,35,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-77' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 78
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-laptops'),'DUMMY-SPU-78','苹果 MacBook Pro 14 英寸深空灰','','苹果','https://cdn.dummyjson.com/product-images/laptops/apple-macbook-pro-14-inch-space-grey/thumbnail.webp','这款深空灰色 14 英寸 MacBook Pro 轻薄利落、性能强劲，搭载 Apple M1 Pro 芯片，带来出色性能和惊艳的 Retina 显示屏。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-78');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-78','苹果 MacBook Pro 14 英寸深空灰',JSON_OBJECT(),1999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-78');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/laptops/apple-macbook-pro-14-inch-space-grey/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/laptops/apple-macbook-pro-14-inch-space-grey/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,24,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-78',24,24,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-78' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 79
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-laptops'),'DUMMY-SPU-79','华硕 Zenbook Pro 双屏笔记本电脑','','华硕','https://cdn.dummyjson.com/product-images/laptops/asus-zenbook-pro-dual-screen-laptop/thumbnail.webp','华硕 Zenbook Pro 双屏笔记本电脑性能出众，配备双屏，为创意专业人士带来高效生产力与灵活多用体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-79');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-79','华硕 Zenbook Pro 双屏笔记本电脑',JSON_OBJECT(),1799.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-79');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/laptops/asus-zenbook-pro-dual-screen-laptop/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/laptops/asus-zenbook-pro-dual-screen-laptop/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,45,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-79',45,45,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-79' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 80
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-laptops'),'DUMMY-SPU-80','华为 MateBook X Pro','','华为','https://cdn.dummyjson.com/product-images/laptops/huawei-matebook-x-pro/thumbnail.webp','华为 MateBook X Pro 是一款纤薄时尚的笔记本电脑，配备高分辨率触控屏，为移动办公用户带来高端使用体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-80');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-80','华为 MateBook X Pro',JSON_OBJECT(),1399.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-80');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/laptops/huawei-matebook-x-pro/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/laptops/huawei-matebook-x-pro/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-80',75,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-80' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 81
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-laptops'),'DUMMY-SPU-81','联想 Yoga 920','','联想','https://cdn.dummyjson.com/product-images/laptops/lenovo-yoga-920/thumbnail.webp','联想 Yoga 920 是一款二合一变形笔记本电脑，配有灵活转轴，可在笔记本电脑和平板电脑模式间切换，兼具多用途与便携性。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-81');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-81','联想 Yoga 920',JSON_OBJECT(),1099.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-81');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/laptops/lenovo-yoga-920/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/laptops/lenovo-yoga-920/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-81',40,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-81' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 82
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-laptops'),'DUMMY-SPU-82','全新戴尔 XPS 13 9300 笔记本电脑','','戴尔','https://cdn.dummyjson.com/product-images/laptops/new-dell-xps-13-9300-laptop/thumbnail.webp','全新戴尔 XPS 13 9300 是一款小巧而强劲的设备，配备近乎无边框的 InfinityEdge 显示屏，并拥有高端性能，可胜任各种任务。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-82');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-82','全新戴尔 XPS 13 9300 笔记本电脑',JSON_OBJECT(),1499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-82');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/laptops/new-dell-xps-13-9300-laptop/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/laptops/new-dell-xps-13-9300-laptop/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,74,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-82',74,74,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-82' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 83
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shirts'),'DUMMY-SPU-83','蓝黑格纹衬衫','','时尚潮流','https://cdn.dummyjson.com/product-images/mens-shirts/blue-&-black-check-shirt/thumbnail.webp','这款蓝黑格纹衬衫时尚舒适，是一款经典男士衬衫。采用优质面料，休闲场合和半正式场合都适合穿着。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-83');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-83','蓝黑格纹衬衫',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-83');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shirts/blue-&-black-check-shirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shirts/blue-&-black-check-shirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,38,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-83',38,38,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-83' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 84
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shirts'),'DUMMY-SPU-84','技嘉 AORUS 男士 T 恤','','技嘉','https://cdn.dummyjson.com/product-images/mens-shirts/gigabyte-aorus-men-tshirt/thumbnail.webp','这款技嘉 AORUS 男士 T 恤风格酷感休闲，专为游戏爱好者设计。衣身饰有 AORUS 标志，设计简洁利落，适合展现你的游戏风格。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-84');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-84','技嘉 AORUS 男士 T 恤',JSON_OBJECT(),24.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-84');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shirts/gigabyte-aorus-men-tshirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shirts/gigabyte-aorus-men-tshirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-84',90,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-84' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 85
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shirts'),'DUMMY-SPU-85','男士格纹衬衫','','经典穿搭','https://cdn.dummyjson.com/product-images/mens-shirts/man-plaid-shirt/thumbnail.webp','这款男士格纹衬衫经典百搭，采用经典格纹图案。版型舒适、风格休闲，适合多种场合，是衣橱必备单品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-85');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-85','男士格纹衬衫',JSON_OBJECT(),34.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-85');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shirts/man-plaid-shirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shirts/man-plaid-shirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-85',82,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-85' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 86
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shirts'),'DUMMY-SPU-86','男士短袖衬衫','','休闲舒适','https://cdn.dummyjson.com/product-images/mens-shirts/man-short-sleeve-shirt/thumbnail.webp','这款男士短袖衬衫轻盈透气、时尚有型，适合温暖天气穿着。舒适的版型搭配短袖设计，轻松打造随性又得体的造型。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-86');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-86','男士短袖衬衫',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-86');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shirts/man-short-sleeve-shirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shirts/man-short-sleeve-shirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,2,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-86',2,2,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-86' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 87
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shirts'),'DUMMY-SPU-87','男士格纹衬衫','','都市风尚','https://cdn.dummyjson.com/product-images/mens-shirts/men-check-shirt/thumbnail.webp','这款男士衬衫采用时尚格纹图案，经典又百搭，适合多种场合，为衣橱造型增添干练得体的气质。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-87');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-87','男士格纹衬衫',JSON_OBJECT(),27.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-87');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shirts/men-check-shirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shirts/men-check-shirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-87',95,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-87' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 88
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shoes'),'DUMMY-SPU-88','耐克 Air Jordan 1 红黑配色','','耐克','https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/thumbnail.webp','这款红黑配色 Nike Air Jordan 1 是标志性篮球鞋，以时尚设计和出色性能著称，深受球鞋爱好者和运动员喜爱。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-88');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-88','耐克 Air Jordan 1 红黑配色',JSON_OBJECT(),149.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-88');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shoes/nike-air-jordan-1-red-and-black/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-88',7,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-88' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 89
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shoes'),'DUMMY-SPU-89','耐克棒球钉鞋','','耐克','https://cdn.dummyjson.com/product-images/mens-shoes/nike-baseball-cleats/thumbnail.webp','耐克棒球钉鞋专为在棒球场上提供强劲抓地力和出色表现而设计。无论比赛还是训练，都能为球员提供稳定支撑。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-89');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-89','耐克棒球钉鞋',JSON_OBJECT(),79.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-89');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shoes/nike-baseball-cleats/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shoes/nike-baseball-cleats/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,12,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-89',12,12,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-89' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 90
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shoes'),'DUMMY-SPU-90','彪马 Future Rider 休闲运动鞋','','彪马','https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/thumbnail.webp','彪马 Future Rider 运动鞋融合复古风格与现代舒适感，适合日常休闲穿着，为每天出行提供时尚又舒适的选择。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-90');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-90','彪马 Future Rider 休闲运动鞋',JSON_OBJECT(),89.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-90');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shoes/puma-future-rider-trainers/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-90',90,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-90' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 91
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shoes'),'DUMMY-SPU-91','米白与红色运动鞋','','欧孚怀特','https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-&-red/thumbnail.webp','这款米白与红色搭配的运动鞋兼具时尚与实用，是运动爱好者的潮流之选。红色与米白色的组合醒目大胆，为整体造型增添活力。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-91');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-91','米白与红色运动鞋',JSON_OBJECT(),119.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-91');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-&-red/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-&-red/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,17,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-91',17,17,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-91' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 92
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-shoes'),'DUMMY-SPU-92','米白红色运动鞋','','欧孚怀特','https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-red/thumbnail.webp','这款米白红色运动鞋是另一种设计独特的款式，兼具时尚感与舒适度，适合休闲场合穿着。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-92');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-92','米白红色运动鞋',JSON_OBJECT(),109.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-92');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-red/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-shoes/sports-sneakers-off-white-red/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,62,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-92',62,62,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-92' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 93
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-watches'),'DUMMY-SPU-93','棕色皮带腕表','','时尚腕表','https://cdn.dummyjson.com/product-images/mens-watches/brown-leather-belt-watch/thumbnail.webp','这款棕色皮带腕表设计经典、风格时尚。配有真皮表带和简洁利落的表盘，为整体造型增添优雅气质。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-93');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-93','棕色皮带腕表',JSON_OBJECT(),89.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-93');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-watches/brown-leather-belt-watch/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-watches/brown-leather-belt-watch/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,32,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-93',32,32,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-93' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 94
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-watches'),'DUMMY-SPU-94','浪琴 Master Collection 名匠系列','','浪琴','https://cdn.dummyjson.com/product-images/mens-watches/longines-master-collection/thumbnail.webp','浪琴 Master Collection 名匠系列腕表优雅精致，以精准走时和精湛工艺闻名。隽永的设计使其成为奢华与品位的象征。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-94');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-94','浪琴 Master Collection 名匠系列',JSON_OBJECT(),1499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-94');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-watches/longines-master-collection/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-watches/longines-master-collection/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,100,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-94',100,100,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-94' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 95
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-watches'),'DUMMY-SPU-95','劳力士 Cellini Date 黑盘腕表','','劳力士','https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-date-black-dial/thumbnail.webp','这款黑盘劳力士 Cellini Date 腕表经典尊贵，配有黑色表盘和日期显示功能，尽显优雅气质，也彰显劳力士的品牌传承。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-95');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-95','劳力士 Cellini Date 黑盘腕表',JSON_OBJECT(),8999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-95');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-date-black-dial/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-date-black-dial/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-95',40,40,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-95' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 96
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-watches'),'DUMMY-SPU-96','劳力士 Cellini Moonphase 月相腕表','','劳力士','https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-moonphase/thumbnail.webp','劳力士 Cellini Moonphase 月相腕表堪称制表杰作，配备月相显示功能，设计精美。它体现了劳力士对精准与优雅的不懈追求。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-96');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-96','劳力士 Cellini Moonphase 月相腕表',JSON_OBJECT(),12999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-96');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-moonphase/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-watches/rolex-cellini-moonphase/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,36,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-96',36,36,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-96' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 97
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-watches'),'DUMMY-SPU-97','劳力士 Datejust 日志型腕表','','劳力士','https://cdn.dummyjson.com/product-images/mens-watches/rolex-datejust/thumbnail.webp','劳力士 Datejust 是一款标志性且百搭的腕表，配有日期窗。它以隽永设计和可靠性能闻名，是劳力士卓越制表工艺的象征。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-97');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-97','劳力士 Datejust 日志型腕表',JSON_OBJECT(),10999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-97');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-watches/rolex-datejust/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-watches/rolex-datejust/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-97',86,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-97' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 98
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mens-watches'),'DUMMY-SPU-98','劳力士 Submariner 潜航者腕表','','劳力士','https://cdn.dummyjson.com/product-images/mens-watches/rolex-submariner-watch/thumbnail.webp','劳力士 Submariner 潜航者是一款传奇潜水腕表，拥有悠久历史。它以坚固耐用和防水性能著称，是冒险与探索精神的象征。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-98');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-98','劳力士 Submariner 潜航者腕表',JSON_OBJECT(),13999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-98');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mens-watches/rolex-submariner-watch/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mens-watches/rolex-submariner-watch/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,55,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-98',55,55,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-98' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 99
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-99','亚马逊 Echo Plus 智能音箱','','亚马逊','https://cdn.dummyjson.com/product-images/mobile-accessories/amazon-echo-plus/thumbnail.webp','亚马逊 Echo Plus 是一款内置 Alexa 语音控制功能的智能音箱，音质出色，还可作为控制智能家居设备的中枢。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-99');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-99','亚马逊 Echo Plus 智能音箱',JSON_OBJECT(),99.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-99');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/amazon-echo-plus/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/amazon-echo-plus/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,61,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-99',61,61,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-99' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 100
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-100','苹果 AirPods','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpods/thumbnail.webp','Apple AirPods 带来流畅便捷的无线聆听体验，支持轻松配对，音质出色并集成 Siri，适合随时随地聆听。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-100');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-100','苹果 AirPods',JSON_OBJECT(),129.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-100');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpods/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpods/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,67,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-100',67,67,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-100' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 101
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-101','苹果 AirPods Max 银色头戴式耳机','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpods-max-silver/thumbnail.webp','苹果 AirPods Max 银色款是一款高端头戴式耳机，具备高保真音质、自适应均衡和主动降噪功能，带来沉浸式聆听体验，同时兼具时尚外观。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-101');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-101','苹果 AirPods Max 银色头戴式耳机',JSON_OBJECT(),549.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-101');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpods-max-silver/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpods-max-silver/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-101',59,59,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-101' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 102
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-102','苹果 AirPower 无线充电器','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpower-wireless-charger/thumbnail.webp','苹果 AirPower 无线充电器让兼容的苹果设备无线充电更加方便。只需将设备放在充电板上，即可轻松充电。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-102');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-102','苹果 AirPower 无线充电器',JSON_OBJECT(),79.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-102');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpower-wireless-charger/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-airpower-wireless-charger/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-102',1,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-102' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 103
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-103','苹果 HomePod mini 太空灰智能音箱','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-homepod-mini-cosmic-grey/thumbnail.webp','苹果 HomePod mini 太空灰款是一款小巧的智能音箱，音效出色，并可与苹果生态系统无缝协作，打造智能家居体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-103');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-103','苹果 HomePod mini 太空灰智能音箱',JSON_OBJECT(),99.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-103');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-homepod-mini-cosmic-grey/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-homepod-mini-cosmic-grey/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-103',27,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-103' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 104
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-104','苹果 iPhone 充电器','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-iphone-charger/thumbnail.webp','这款苹果 iPhone 充电器品质可靠，专为 iPhone 快速、高效充电而设计，让设备随时保持电量充足、随时可用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-104');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-104','苹果 iPhone 充电器',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-104');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-iphone-charger/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-iphone-charger/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,31,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-104',31,31,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-104' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 105
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-105','苹果 MagSafe 磁吸电池','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-magsafe-battery-pack/thumbnail.webp','苹果 MagSafe 磁吸电池可便捷地为兼容 MagSafe 的 iPhone 补充电量。将它磁吸在手机上即可稳固连接。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-105');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-105','苹果 MagSafe 磁吸电池',JSON_OBJECT(),99.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-105');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-magsafe-battery-pack/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-magsafe-battery-pack/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-105',1,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-105' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 106
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-106','苹果 Watch Series 4 金色智能手表','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/apple-watch-series-4-gold/thumbnail.webp','苹果 Watch Series 4 金色款外观时尚、功能先进，支持心率监测、健身追踪，并配有精美的 Retina 显示屏。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-106');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-106','苹果 Watch Series 4 金色智能手表',JSON_OBJECT(),349.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-106');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/apple-watch-series-4-gold/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/apple-watch-series-4-gold/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,33,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-106',33,33,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-106' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 107
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-107','比茨 Flex 无线耳机','','比茨','https://cdn.dummyjson.com/product-images/mobile-accessories/beats-flex-wireless-earphones/thumbnail.webp','Beats Flex 无线耳机佩戴舒适，适用场景多样。耳机支持磁吸收纳，续航最长可达 12 小时，适合日常使用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-107');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-107','比茨 Flex 无线耳机',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-107');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/beats-flex-wireless-earphones/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/beats-flex-wireless-earphones/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,50,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-107',50,50,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-107' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 108
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-108','iPhone 12 MagSafe 矽胶保护壳 李子紫','','苹果','https://cdn.dummyjson.com/product-images/mobile-accessories/iphone-12-silicone-case-with-magsafe-plum/thumbnail.webp','这款李子紫色 iPhone 12 矽胶保护壳兼具时尚外观与防护功能，专为 iPhone 12 设计，并支持 MagSafe，方便吸附各类配件。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-108');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-108','iPhone 12 MagSafe 矽胶保护壳 李子紫',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-108');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/iphone-12-silicone-case-with-magsafe-plum/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/iphone-12-silicone-case-with-magsafe-plum/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,69,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-108',69,69,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-108' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 109
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-109','单脚架','','科技装备','https://cdn.dummyjson.com/product-images/mobile-accessories/monopod/thumbnail.webp','这款单脚架是用途灵活的相机配件，可帮助稳定拍摄并调节拍摄角度，适合轻松拍摄自拍、合影和视频。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-109');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-109','单脚架',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-109');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/monopod/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/monopod/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,48,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-109',48,48,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-109' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 110
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-110','适用于 iPhone 的自拍补光灯','','数码大师','https://cdn.dummyjson.com/product-images/mobile-accessories/selfie-lamp-with-iphone/thumbnail.webp','这款便携、可调节的 LED 补光灯专为提升自拍和视频通话效果而设计。将它夹在 iPhone 上，即可拍出光线充足的照片。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-110');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-110','适用于 iPhone 的自拍补光灯',JSON_OBJECT(),14.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-110');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/selfie-lamp-with-iphone/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/selfie-lamp-with-iphone/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,58,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-110',58,58,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-110' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 111
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-111','自拍杆单脚架','','快拍科技','https://cdn.dummyjson.com/product-images/mobile-accessories/selfie-stick-monopod/thumbnail.webp','这款自拍杆单脚架可伸缩、可折叠，方便拍出理想的自拍或合影，并兼容智能手机和相机。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-111');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-111','自拍杆单脚架',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-111');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/selfie-stick-monopod/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/selfie-stick-monopod/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,11,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-111',11,11,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-111' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 112
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-mobile-accessories'),'DUMMY-SPU-112','电视演播室摄像机支撑柱','','专业视界','https://cdn.dummyjson.com/product-images/mobile-accessories/tv-studio-camera-pedestal/thumbnail.webp','这套专业级摄像机支撑系统适用于演播室，可实现平稳、精准的镜头移动，适合广播与影视制作。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-112');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-112','电视演播室摄像机支撑柱',JSON_OBJECT(),499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-112');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/mobile-accessories/tv-studio-camera-pedestal/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/mobile-accessories/tv-studio-camera-pedestal/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,15,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-112',15,15,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-112' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 113
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-motorcycle'),'DUMMY-SPU-113','通用型摩托车','','通用摩托（示例品牌）','https://cdn.dummyjson.com/product-images/motorcycle/generic-motorcycle/thumbnail.webp','这款通用型摩托车适应多种骑行需求，性能可靠、用途广泛。均衡的设计带来舒适且高效的骑行体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-113');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-113','通用型摩托车',JSON_OBJECT(),3999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-113');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/motorcycle/generic-motorcycle/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/motorcycle/generic-motorcycle/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-113',34,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-113' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 114
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-motorcycle'),'DUMMY-SPU-114','川崎 Z800','','川崎','https://cdn.dummyjson.com/product-images/motorcycle/kawasaki-z800/thumbnail.webp','川崎 Z800 是一款动力强劲、操控灵活的运动摩托车，以醒目的设计和出色性能著称。它配备先进功能，深受摩托车爱好者喜爱。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-114');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-114','川崎 Z800',JSON_OBJECT(),8999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-114');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/motorcycle/kawasaki-z800/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/motorcycle/kawasaki-z800/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,52,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-114',52,52,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-114' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 115
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-motorcycle'),'DUMMY-SPU-115','摩托大奖赛 CI.H1','','摩托大奖赛','https://cdn.dummyjson.com/product-images/motorcycle/motogp-ci.h1/thumbnail.webp','MotoGP CI.H1 是一款汲取 MotoGP 赛车技术灵感的高性能摩托车，采用前沿配置与精密工程设计，带来畅快刺激的骑行体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-115');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-115','摩托大奖赛 CI.H1',JSON_OBJECT(),14999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-115');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/motorcycle/motogp-ci.h1/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/motorcycle/motogp-ci.h1/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,10,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-115',10,10,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-115' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 116
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-motorcycle'),'DUMMY-SPU-116','踏板摩托车','','踏板大师','https://cdn.dummyjson.com/product-images/motorcycle/scooter-motorcycle/thumbnail.webp','这款踏板摩托车实用省油，适合城市通勤。采用跨步式车架设计，操控简单灵活，骑行轻松方便。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-116');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-116','踏板摩托车',JSON_OBJECT(),2999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-116');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/motorcycle/scooter-motorcycle/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/motorcycle/scooter-motorcycle/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-116',84,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-116' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 117
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-motorcycle'),'DUMMY-SPU-117','运动型摩托车','','极速大师','https://cdn.dummyjson.com/product-images/motorcycle/sportbike-motorcycle/thumbnail.webp','这款运动型摩托车专为速度与灵活操控而设计，车身线条流畅、空气动力学造型鲜明，适合追求动感刺激骑行体验的用户。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-117');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-117','运动型摩托车',JSON_OBJECT(),7499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-117');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/motorcycle/sportbike-motorcycle/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/motorcycle/sportbike-motorcycle/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-117',0,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-117' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 118
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-skin-care'),'DUMMY-SPU-118','爱态度 Super Leaves 洁手皂','','爱态度','https://cdn.dummyjson.com/product-images/skin-care/attitude-super-leaves-hand-soap/thumbnail.webp','Attitude Super Leaves 洁手皂融入植物精华，温和滋养双手。它能清洁并滋润肌肤，洗后双手清爽柔软。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-118');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-118','爱态度 Super Leaves 洁手皂',JSON_OBJECT(),8.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-118');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/skin-care/attitude-super-leaves-hand-soap/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/skin-care/attitude-super-leaves-hand-soap/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,94,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-118',94,94,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-118' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 119
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-skin-care'),'DUMMY-SPU-119','玉兰油 超滋润乳木果身体沐浴露','','玉兰油','https://cdn.dummyjson.com/product-images/skin-care/olay-ultra-moisture-shea-butter-body-wash/thumbnail.webp','Olay 超滋润乳木果身体沐浴露能借助乳木果的滋润力为肌肤补水滋养。泡沫丰富细腻，洗后肌肤柔滑如丝。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-119');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-119','玉兰油 超滋润乳木果身体沐浴露',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-119');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/skin-care/olay-ultra-moisture-shea-butter-body-wash/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/skin-care/olay-ultra-moisture-shea-butter-body-wash/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-119',34,34,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-119' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 120
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-skin-care'),'DUMMY-SPU-120','凡士林男士身体及面部润肤乳','','凡士林','https://cdn.dummyjson.com/product-images/skin-care/vaseline-men-body-and-face-lotion/thumbnail.webp','凡士林男士身体及面部润肤乳专为男性肌肤配制，提供持久滋润。质地吸收迅速，帮助肌肤保持水润健康。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-120');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-120','凡士林男士身体及面部润肤乳',JSON_OBJECT(),9.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-120');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/skin-care/vaseline-men-body-and-face-lotion/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/skin-care/vaseline-men-body-and-face-lotion/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-120',95,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-120' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 121
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-121','苹果 iPhone 5s 智能手机','','苹果','https://cdn.dummyjson.com/product-images/smartphones/iphone-5s/thumbnail.webp','iPhone 5s 是一款经典智能手机，发布时以小巧机身和先进功能著称。虽然机型较旧，仍能提供可靠的使用体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-121');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-121','苹果 iPhone 5s 智能手机',JSON_OBJECT(),199.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-121');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/iphone-5s/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/iphone-5s/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,25,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-121',25,25,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-121' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 122
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-122','苹果 iPhone 6 智能手机','','苹果','https://cdn.dummyjson.com/product-images/smartphones/iphone-6/thumbnail.webp','iPhone 6 外观时尚、性能可靠，配备更大的屏幕并提升了运行表现。它带来了多项新功能与设计变化，曾广受欢迎。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-122');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-122','苹果 iPhone 6 智能手机',JSON_OBJECT(),299.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-122');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/iphone-6/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/iphone-6/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,60,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-122',60,60,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-122' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 123
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-123','苹果 iPhone 13 Pro 智能手机','','苹果','https://cdn.dummyjson.com/product-images/smartphones/iphone-13-pro/thumbnail.webp','iPhone 13 Pro 是一款先进的智能手机，配备强大的相机系统、高性能芯片和出色显示屏，为追求顶尖科技体验的用户提供丰富功能。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-123');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-123','苹果 iPhone 13 Pro 智能手机',JSON_OBJECT(),1099.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-123');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/iphone-13-pro/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/iphone-13-pro/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,56,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-123',56,56,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-123' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 124
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-124','苹果 iPhone X 智能手机','','苹果','https://cdn.dummyjson.com/product-images/smartphones/iphone-x/thumbnail.webp','iPhone X 是一款旗舰智能手机，配备近乎无边框的 OLED 屏幕、Face ID 面部识别和出色性能，是 iPhone 设计与创新的重要里程碑。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-124');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-124','苹果 iPhone X 智能手机',JSON_OBJECT(),899.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-124');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/iphone-x/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/iphone-x/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,37,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-124',37,37,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-124' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 125
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-125','欧珀 OPPO A57 智能手机','','欧珀','https://cdn.dummyjson.com/product-images/smartphones/oppo-a57/thumbnail.webp','OPPO A57 是一款中端智能手机，设计简洁时尚，功能实用，在性能与价格之间取得平衡，因此颇受欢迎。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-125');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-125','欧珀 OPPO A57 智能手机',JSON_OBJECT(),249.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-125');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/oppo-a57/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/oppo-a57/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,19,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-125',19,19,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-125' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 126
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-126','欧珀 OPPO F19 Pro+ 智能手机','','欧珀','https://cdn.dummyjson.com/product-images/smartphones/oppo-f19-pro-plus/thumbnail.webp','OPPO F19 Pro+ 是一款功能丰富、注重影像能力的智能手机，配备先进的摄影功能和强劲性能，带来高端使用体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-126');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-126','欧珀 OPPO F19 Pro+ 智能手机',JSON_OBJECT(),399.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-126');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/oppo-f19-pro-plus/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/oppo-f19-pro-plus/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,78,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-126',78,78,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-126' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 127
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-127','OPPO K1 系列手机','','欧珀','https://cdn.dummyjson.com/product-images/smartphones/oppo-k1/thumbnail.webp','OPPO K1 系列提供多款功能与规格各异的智能手机。该系列以时尚设计和可靠性能著称，可满足不同用户的偏好。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-127');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-127','OPPO K1 系列手机',JSON_OBJECT(),299.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-127');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/oppo-k1/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/oppo-k1/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,55,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-127',55,55,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-127' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 128
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-128','真我 realme C35 智能手机','','真我','https://cdn.dummyjson.com/product-images/smartphones/realme-c35/thumbnail.webp','realme C35 是一款价格亲民的智能手机，着重满足日常使用所需。它性能可靠，操作体验简便。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-128');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-128','真我 realme C35 智能手机',JSON_OBJECT(),149.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-128');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/realme-c35/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/realme-c35/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,48,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-128',48,48,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-128' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 129
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-129','真我 realme X 智能手机','','真我','https://cdn.dummyjson.com/product-images/smartphones/realme-x/thumbnail.webp','realme X 是一款中端智能手机，以简洁流畅的设计和出色屏幕著称。它在性能与拍照能力之间取得良好平衡，适合希望选购优质设备的用户。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-129');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-129','真我 realme X 智能手机',JSON_OBJECT(),299.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-129');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/realme-x/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/realme-x/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,12,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-129',12,12,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-129' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 130
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-130','真我 realme XT 智能手机','','真我','https://cdn.dummyjson.com/product-images/smartphones/realme-xt/thumbnail.webp','realme XT 是一款注重影像技术、功能丰富的智能手机，配备先进的相机传感器，可拍摄高质量照片和视频，适合摄影爱好者。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-130');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-130','真我 realme XT 智能手机',JSON_OBJECT(),349.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-130');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/realme-xt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/realme-xt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,80,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-130',80,80,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-130' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 131
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-131','三星 Galaxy S7','','三星','https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s7/thumbnail.webp','三星 Galaxy S7 是一款旗舰智能手机，设计简洁时尚，功能先进，配备高分辨率屏幕、强劲相机和可靠性能。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-131');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-131','三星 Galaxy S7',JSON_OBJECT(),299.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-131');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s7/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s7/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,67,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-131',67,67,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-131' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 132
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-132','三星 Galaxy S8','','三星','https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s8/thumbnail.webp','三星 Galaxy S8 是一款高端智能手机，配备 Infinity Display 全视曲面屏，带来出色的视觉体验，并拥有先进的相机功能和前沿技术。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-132');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-132','三星 Galaxy S8',JSON_OBJECT(),499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-132');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s8/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s8/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-132',0,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-132' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 133
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-133','三星 Galaxy S10','','三星','https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s10/thumbnail.webp','三星 Galaxy S10 是一款旗舰手机，配备动态 AMOLED 屏幕、多功能相机系统和强劲性能，展现智能手机技术上的创新与实力。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-133');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-133','三星 Galaxy S10',JSON_OBJECT(),699.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-133');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s10/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/samsung-galaxy-s10/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,19,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-133',19,19,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-133' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 134
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-134','维沃 vivo S1 智能手机','','维沃','https://cdn.dummyjson.com/product-images/smartphones/vivo-s1/thumbnail.webp','vivo S1 是一款兼顾设计与性能的中端智能手机，配备色彩鲜明的屏幕、实用的相机系统和稳定可靠的功能表现。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-134');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-134','维沃 vivo S1 智能手机',JSON_OBJECT(),249.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-134');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/vivo-s1/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/vivo-s1/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,50,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-134',50,50,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-134' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 135
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-135','维沃 vivo V9 智能手机','','维沃','https://cdn.dummyjson.com/product-images/smartphones/vivo-v9/thumbnail.webp','vivo V9 是一款外观流畅、注重自拍画质的智能手机，配备刘海屏和双摄系统，设计风格现代。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-135');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-135','维沃 vivo V9 智能手机',JSON_OBJECT(),299.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-135');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/vivo-v9/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/vivo-v9/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-135',82,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-135' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 136
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-smartphones'),'DUMMY-SPU-136','维沃 vivo X21 智能手机','','维沃','https://cdn.dummyjson.com/product-images/smartphones/vivo-x21/thumbnail.webp','vivo X21 是一款注重前沿科技的高端智能手机，配备屏下指纹传感器、高分辨率屏幕和先进的相机功能。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-136');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-136','维沃 vivo X21 智能手机',JSON_OBJECT(),499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-136');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/smartphones/vivo-x21/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/smartphones/vivo-x21/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-136',7,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-136' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 137
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-137','美式橄榄球','','','https://cdn.dummyjson.com/product-images/sports-accessories/american-football/thumbnail.webp','这是一款用于美式橄榄球比赛的经典用球，专为投掷和接球设计，是这项运动的必备装备。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-137');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-137','美式橄榄球',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-137');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/american-football/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/american-football/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-137',53,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-137' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 138
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-138','棒球','','','https://cdn.dummyjson.com/product-images/sports-accessories/baseball-ball/thumbnail.webp','这是一款标准棒球，采用耐用的皮革外层，适用于投球、击球以及棒球比赛中的防守接球。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-138');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-138','棒球',JSON_OBJECT(),8.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-138');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/baseball-ball/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/baseball-ball/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,100,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-138',100,100,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-138' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 139
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-139','棒球手套','','','https://cdn.dummyjson.com/product-images/sports-accessories/baseball-glove/thumbnail.webp','这款防护手套供棒球运动员佩戴，用于接球和防守，让球员在比赛中佩戴舒适、控球自如。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-139');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-139','棒球手套',JSON_OBJECT(),24.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-139');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/baseball-glove/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/baseball-glove/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,22,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-139',22,22,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-139' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 140
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-140','篮球','','','https://cdn.dummyjson.com/product-images/sports-accessories/basketball/thumbnail.webp','这是一款标准篮球，适用于运球、投篮和传球，可在室内或室外场地使用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-140');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-140','篮球',JSON_OBJECT(),14.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-140');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/basketball/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/basketball/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-140',75,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-140' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 141
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-141','篮球篮圈','','','https://cdn.dummyjson.com/product-images/sports-accessories/basketball-rim/thumbnail.webp','这套结实耐用的篮圈和篮网组件安装在篮球篮板上，为篮球投篮与得分提供目标。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-141');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-141','篮球篮圈',JSON_OBJECT(),39.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-141');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/basketball-rim/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/basketball-rim/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,43,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-141',43,43,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-141' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 142
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-142','板球','','','https://cdn.dummyjson.com/product-images/sports-accessories/cricket-ball/thumbnail.webp','这是一种用于板球运动的硬质皮革球。比赛中由投球手投出、击球手击打，其硬度和接缝都会影响比赛过程。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-142');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-142','板球',JSON_OBJECT(),12.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-142');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/cricket-ball/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/cricket-ball/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,30,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-142',30,30,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-142' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 143
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-143','板球球棒','','','https://cdn.dummyjson.com/product-images/sports-accessories/cricket-bat/thumbnail.webp','板球球棒是板球运动的重要装备，供击球手用来击打板球。球棒由木材制成，有多种尺寸和款式可选。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-143');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-143','板球球棒',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-143');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/cricket-bat/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/cricket-bat/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,98,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-143',98,98,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-143' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 144
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-144','板球头盔','','','https://cdn.dummyjson.com/product-images/sports-accessories/cricket-helmet/thumbnail.webp','这款防护头盔供板球运动员佩戴，尤其适合击球手和守门员，可帮助抵御快速投球和弹跳球的冲击。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-144');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-144','板球头盔',JSON_OBJECT(),44.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-144');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/cricket-helmet/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/cricket-helmet/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,10,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-144',10,10,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-144' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 145
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-145','板球三柱门','','','https://cdn.dummyjson.com/product-images/sports-accessories/cricket-wicket/thumbnail.webp','这套板球三柱门由三根门柱和两根横木组成。击球手在得分时也要设法保护三柱门。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-145');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-145','板球三柱门',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-145');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/cricket-wicket/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/cricket-wicket/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,25,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-145',25,25,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-145' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 146
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-146','羽毛球','','','https://cdn.dummyjson.com/product-images/sports-accessories/feather-shuttlecock/thumbnail.webp','这款羽毛球用于羽毛球运动，采用天然羽毛，专为高速对打设计，在比赛中提供稳定飞行和精准落点。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-146');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-146','羽毛球',JSON_OBJECT(),5.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-146');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/feather-shuttlecock/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/feather-shuttlecock/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-146',95,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-146' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 147
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-147','足球','','','https://cdn.dummyjson.com/product-images/sports-accessories/football/thumbnail.webp','这是一款标准足球，也称英式足球，适用于足球运动，专为比赛中的踢球和传球而设计。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-147');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-147','足球',JSON_OBJECT(),17.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-147');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/football/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/football/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,96,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-147',96,96,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-147' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 148
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-148','高尔夫球','','','https://cdn.dummyjson.com/product-images/sports-accessories/golf-ball/thumbnail.webp','这是一款用于高尔夫运动的小球，表面的凹坑有助于提升空气动力效果；被球杆击打后，可获得更好的飞行距离。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-148');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-148','高尔夫球',JSON_OBJECT(),9.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-148');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/golf-ball/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/golf-ball/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-148',84,84,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-148' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 149
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-149','高尔夫铁杆','','','https://cdn.dummyjson.com/product-images/sports-accessories/iron-golf/thumbnail.webp','这是一种适用于多种击球场景的高尔夫球杆，配有坚实的金属杆头，可用于攻果岭击球、切击及其他高尔夫技术动作。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-149');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-149','高尔夫铁杆',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-149');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/iron-golf/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/iron-golf/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-149',90,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-149' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 150
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-150','金属棒球棒','','','https://cdn.dummyjson.com/product-images/sports-accessories/metal-baseball-bat/thumbnail.webp','这款棒球棒结实耐用且重量轻，由金属合金制成，常用于棒球比赛击球和日常击球练习。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-150');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-150','金属棒球棒',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-150');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/metal-baseball-bat/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/metal-baseball-bat/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,16,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-150',16,16,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-150' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 151
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-151','网球','','','https://cdn.dummyjson.com/product-images/sports-accessories/tennis-ball/thumbnail.webp','标准网球运动用球，专为在比赛或练习中弹跳并由网球拍击打而设计。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-151');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-151','网球',JSON_OBJECT(),6.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-151');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/tennis-ball/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/tennis-ball/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,28,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-151',28,28,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-151' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 152
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-152','网球拍','','','https://cdn.dummyjson.com/product-images/sports-accessories/tennis-racket/thumbnail.webp','网球运动必备装备，配有拍框、拍线和握柄，便于球员击打网球。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-152');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-152','网球拍',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-152');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/tennis-racket/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/tennis-racket/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,6,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-152',6,6,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-152' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 153
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sports-accessories'),'DUMMY-SPU-153','排球','','','https://cdn.dummyjson.com/product-images/sports-accessories/volleyball/thumbnail.webp','标准排球运动用球，适合在排球比赛中用于垫球、传球和扣球过网。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-153');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-153','排球',JSON_OBJECT(),11.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-153');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sports-accessories/volleyball/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sports-accessories/volleyball/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-153',0,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-153' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 154
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sunglasses'),'DUMMY-SPU-154','黑色太阳镜','','时尚镜饰','https://cdn.dummyjson.com/product-images/sunglasses/black-sun-glasses/thumbnail.webp','经典又时尚的款式，采用流畅的黑色镜框和有色镜片，兼具紫外线防护与时尚外观。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-154');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-154','黑色太阳镜',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-154');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sunglasses/black-sun-glasses/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sunglasses/black-sun-glasses/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,60,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-154',60,60,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-154' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 155
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sunglasses'),'DUMMY-SPU-155','经典太阳镜','','时尚镜饰','https://cdn.dummyjson.com/product-images/sunglasses/classic-sun-glasses/thumbnail.webp','采用经久耐看的设计，搭配中性色镜框和具备紫外线防护功能的镜片。这款太阳镜百搭，适合多种场合。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-155');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-155','经典太阳镜',JSON_OBJECT(),24.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-155');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sunglasses/classic-sun-glasses/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sunglasses/classic-sun-glasses/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-155',1,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-155' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 156
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sunglasses'),'DUMMY-SPU-156','绿黑配色眼镜','','时尚镜饰','https://cdn.dummyjson.com/product-images/sunglasses/green-and-black-glasses/thumbnail.webp','以醒目的绿色与黑色搭配，为你的眼镜收藏增添活力；兼具时尚感与吸睛效果。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-156');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-156','绿黑配色眼镜',JSON_OBJECT(),34.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-156');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sunglasses/green-and-black-glasses/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sunglasses/green-and-black-glasses/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,24,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-156',24,24,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-156' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 157
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sunglasses'),'DUMMY-SPU-157','派对眼镜','','时尚趣玩','https://cdn.dummyjson.com/product-images/sunglasses/party-glasses/thumbnail.webp','专为派对造型增添亮点而设计。独特的形状或彩色镜框能为庆祝时的装扮增添俏皮趣味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-157');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-157','派对眼镜',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-157');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sunglasses/party-glasses/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sunglasses/party-glasses/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-157',86,86,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-157' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 158
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-sunglasses'),'DUMMY-SPU-158','太阳镜','','时尚镜饰','https://cdn.dummyjson.com/product-images/sunglasses/sunglasses/thumbnail.webp','经典简约的设计，注重实用性；在保持隽永外观的同时，提供基本的紫外线防护。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-158');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-158','太阳镜',JSON_OBJECT(),22.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-158');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/sunglasses/sunglasses/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/sunglasses/sunglasses/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-158',27,27,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-158' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 159
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tablets'),'DUMMY-SPU-159','iPad mini 2021 星光色','','苹果','https://cdn.dummyjson.com/product-images/tablets/ipad-mini-2021-starlight/thumbnail.webp','苹果推出的紧凑而强劲的平板电脑，配备出色的 Retina 显示屏、强大的 A 系列芯片和简洁利落的设计，带来高端平板使用体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-159');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-159','iPad mini 2021 星光色',JSON_OBJECT(),499.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-159');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tablets/ipad-mini-2021-starlight/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tablets/ipad-mini-2021-starlight/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,47,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-159',47,47,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-159' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 160
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tablets'),'DUMMY-SPU-160','三星 Galaxy Tab S8 Plus 灰色','','三星','https://cdn.dummyjson.com/product-images/tablets/samsung-galaxy-tab-s8-plus-grey/thumbnail.webp','三星推出的高性能安卓平板，配备大尺寸 AMOLED 显示屏、强劲处理器并支持 S Pen，适合工作效率场景与娱乐使用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-160');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-160','三星 Galaxy Tab S8 Plus 灰色',JSON_OBJECT(),599.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-160');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tablets/samsung-galaxy-tab-s8-plus-grey/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tablets/samsung-galaxy-tab-s8-plus-grey/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,62,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-160',62,62,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-160' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 161
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tablets'),'DUMMY-SPU-161','三星 Galaxy Tab 白色款','','三星','https://cdn.dummyjson.com/product-images/tablets/samsung-galaxy-tab-white/thumbnail.webp','外观利落、用途多样的白色安卓平板，拥有鲜艳的显示屏、持久续航和多种功能，可为各类任务带来出色的使用体验。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-161');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-161','三星 Galaxy Tab 白色款',JSON_OBJECT(),349.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-161');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tablets/samsung-galaxy-tab-white/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tablets/samsung-galaxy-tab-white/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,92,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-161',92,92,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-161' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 162
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tops'),'DUMMY-SPU-162','蓝色连衣裙','','','https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp','适合多种场合的迷人时尚连衣裙。明快的蓝色与舒适的设计为衣橱增添优雅气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-162');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-162','蓝色连衣裙',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-162');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tops/blue-frock/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,52,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-162',52,52,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-162' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 163
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tops'),'DUMMY-SPU-163','女孩夏季连衣裙','','','https://cdn.dummyjson.com/product-images/tops/girl-summer-dress/thumbnail.webp','为暖和天气设计的可爱轻盈连衣裙，采用活泼图案和轻薄面料，让你在夏日保持凉爽又时尚。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-163');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-163','女孩夏季连衣裙',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-163');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tops/girl-summer-dress/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tops/girl-summer-dress/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,43,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-163',43,43,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-163' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 164
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tops'),'DUMMY-SPU-164','灰色连衣裙','','','https://cdn.dummyjson.com/product-images/tops/gray-dress/thumbnail.webp','适合多种场合的百搭时髦之选。中性的灰色可正式搭配，也可休闲穿着，是注重时尚者衣橱中的必备单品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-164');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-164','灰色连衣裙',JSON_OBJECT(),34.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-164');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tops/gray-dress/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tops/gray-dress/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,55,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-164',55,55,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-164' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 165
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tops'),'DUMMY-SPU-165','短款连衣裙','','','https://cdn.dummyjson.com/product-images/tops/short-frock/thumbnail.webp','活泼时髦的短款连衣裙，适合休闲出行或特别场合，兼顾风格与舒适，打造时尚造型。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-165');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-165','短款连衣裙',JSON_OBJECT(),24.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-165');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tops/short-frock/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tops/short-frock/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,22,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-165',22,22,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-165' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 166
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-tops'),'DUMMY-SPU-166','苏格兰格纹连衣裙','','','https://cdn.dummyjson.com/product-images/tops/tartan-dress/thumbnail.webp','采用经典苏格兰格纹，为衣橱带来隽永而精致的气息。适合秋冬穿着，增添一丝传统韵味。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-166');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-166','苏格兰格纹连衣裙',JSON_OBJECT(),39.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-166');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/tops/tartan-dress/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/tops/tartan-dress/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,73,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-166',73,73,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-166' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 167
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-vehicle'),'DUMMY-SPU-167','克莱斯勒 300 Touring 汽车','','克莱斯勒','https://cdn.dummyjson.com/product-images/vehicle/300-touring/thumbnail.webp','时尚舒适的轿车，以豪华配置和顺畅的驾乘表现著称。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-167');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-167','克莱斯勒 300 Touring 汽车',JSON_OBJECT(),28999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-167');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/vehicle/300-touring/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/vehicle/300-touring/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,54,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-167',54,54,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-167' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 168
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-vehicle'),'DUMMY-SPU-168','Charger SXT 后轮驱动版','','道奇','https://cdn.dummyjson.com/product-images/vehicle/charger-sxt-rwd/thumbnail.webp','动力强劲、富有运动感的后轮驱动轿车，兼顾性能与实用性。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-168');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-168','Charger SXT 后轮驱动版',JSON_OBJECT(),32999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-168');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/vehicle/charger-sxt-rwd/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/vehicle/charger-sxt-rwd/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,57,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-168',57,57,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-168' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 169
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-vehicle'),'DUMMY-SPU-169','道奇 Hornet GT Plus','','道奇','https://cdn.dummyjson.com/product-images/vehicle/dodge-hornet-gt-plus/thumbnail.webp','紧凑灵活的掀背车，适合城市驾驶，并带有运动气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-169');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-169','道奇 Hornet GT Plus',JSON_OBJECT(),24999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-169');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/vehicle/dodge-hornet-gt-plus/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/vehicle/dodge-hornet-gt-plus/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-169',82,82,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-169' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 170
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-vehicle'),'DUMMY-SPU-170','Durango SXT 后轮驱动版','','道奇','https://cdn.dummyjson.com/product-images/vehicle/durango-sxt-rwd/thumbnail.webp','宽敞多用途的 SUV，以强劲性能和适合家庭使用的配置著称。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-170');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-170','Durango SXT 后轮驱动版',JSON_OBJECT(),36999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-170');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/vehicle/durango-sxt-rwd/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/vehicle/durango-sxt-rwd/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-170',95,95,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-170' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 171
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-vehicle'),'DUMMY-SPU-171','克莱斯勒 Pacifica Touring 汽车','','克莱斯勒','https://cdn.dummyjson.com/product-images/vehicle/pacifica-touring/thumbnail.webp','时尚且配置齐全的厢式多功能车，为家庭出行带来舒适与便利。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-171');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-171','克莱斯勒 Pacifica Touring 汽车',JSON_OBJECT(),31999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-171');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/vehicle/pacifica-touring/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/vehicle/pacifica-touring/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-171',53,53,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-171' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 172
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-bags'),'DUMMY-SPU-172','蓝色女士手提包','','时尚达人','https://cdn.dummyjson.com/product-images/womens-bags/blue-women''s-handbag/thumbnail.webp','时尚宽敞，适合日常使用。明快的蓝色搭配多个隔层，兼顾美观与实用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-172');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-172','蓝色女士手提包',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-172');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-bags/blue-women''s-handbag/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-bags/blue-women''s-handbag/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,76,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-172',76,76,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-172' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 173
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-bags'),'DUMMY-SPU-173','Heshe（赫诗） 女士真皮包','','Heshe（赫诗）','https://cdn.dummyjson.com/product-images/womens-bags/heshe-women''s-leather-bag/thumbnail.webp','为成熟优雅的女性打造的奢华优质皮包。设计经久耐看、做工坚固耐用，是一款百搭配饰。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-173');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-173','Heshe（赫诗） 女士真皮包',JSON_OBJECT(),129.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-173');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-bags/heshe-women''s-leather-bag/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-bags/heshe-women''s-leather-bag/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-173',99,99,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-173' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 174
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-bags'),'DUMMY-SPU-174','普拉达女士包','','普拉达','https://cdn.dummyjson.com/product-images/womens-bags/prada-women-bag/thumbnail.webp','彰显优雅与奢华的经典设计师手袋。制作精良并饰有 Prada 标志，是时尚爱好者的个性宣言单品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-174');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-174','普拉达女士包',JSON_OBJECT(),599.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-174');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-bags/prada-women-bag/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-bags/prada-women-bag/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-174',75,75,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-174' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 175
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-bags'),'DUMMY-SPU-175','白色仿皮双肩包','','都市 chic','https://cdn.dummyjson.com/product-images/womens-bags/white-faux-leather-backpack/thumbnail.webp','适合现代女性的时髦实用双肩包。简洁利落的白色外观与充裕收纳空间，休闲出行或随身携带都很合适。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-175');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-175','白色仿皮双肩包',JSON_OBJECT(),39.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-175');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-bags/white-faux-leather-backpack/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-bags/white-faux-leather-backpack/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,39,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-175',39,39,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-175' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 176
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-bags'),'DUMMY-SPU-176','黑色女士手提包','','优雅系列','https://cdn.dummyjson.com/product-images/womens-bags/women-handbag-black/thumbnail.webp','经典百搭的黑色配饰，可搭配多种服装。隽永的黑色与实用设计，使它成为每位女性衣橱里的必备单品。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-176');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-176','黑色女士手提包',JSON_OBJECT(),59.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-176');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-bags/women-handbag-black/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-bags/women-handbag-black/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,11,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-176',11,11,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-176' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 177
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-dresses'),'DUMMY-SPU-177','黑色女士礼服','','','https://cdn.dummyjson.com/product-images/womens-dresses/black-women''s-gown/thumbnail.webp','优雅经典的女士晚礼服。利落的黑色设计适合正式活动和特别场合，尽显精致格调与时尚品位。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-177');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-177','黑色女士礼服',JSON_OBJECT(),129.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-177');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-dresses/black-women''s-gown/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-dresses/black-women''s-gown/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,25,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-177',25,25,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-177' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 178
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-dresses'),'DUMMY-SPU-178','皮革束身胸衣配半身裙','','','https://cdn.dummyjson.com/product-images/womens-dresses/corset-leather-with-skirt/thumbnail.webp','大胆前卫的成套造型，将时尚束身胸衣与配套半身裙组合在一起。适合追求潮流的人士，在各种活动中都能展现鲜明个性。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-178');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-178','皮革束身胸衣配半身裙',JSON_OBJECT(),89.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-178');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-dresses/corset-leather-with-skirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-dresses/corset-leather-with-skirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,30,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-178',30,30,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-178' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 179
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-dresses'),'DUMMY-SPU-179','束身胸衣配黑色半身裙','','','https://cdn.dummyjson.com/product-images/womens-dresses/corset-with-black-skirt/thumbnail.webp','时髦百搭的套装，以流行束身胸衣搭配经典黑色半身裙，为多种场合打造潮流协调的造型。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-179');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-179','束身胸衣配黑色半身裙',JSON_OBJECT(),79.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-179');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-dresses/corset-with-black-skirt/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-dresses/corset-with-black-skirt/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,33,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-179',33,33,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-179' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 180
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-dresses'),'DUMMY-SPU-180','豌豆图案连衣裙','','','https://cdn.dummyjson.com/product-images/womens-dresses/dress-pea/thumbnail.webp','时尚舒适的连衣裙，饰有豌豆图案。适合休闲外出，为衣橱增添活泼有趣的元素，是日常穿着的好选择。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-180');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-180','豌豆图案连衣裙',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-180');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-dresses/dress-pea/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-dresses/dress-pea/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,6,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-180',6,6,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-180' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 181
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-dresses'),'DUMMY-SPU-181','Marni 红黑套装','','Marni（玛尼）','https://cdn.dummyjson.com/product-images/womens-dresses/marni-red-&-black-suit/thumbnail.webp','精致前卫的套装，以红色和黑色相搭配，展现现代设计，塑造大胆自信的造型。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-181');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-181','Marni 红黑套装',JSON_OBJECT(),179.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-181');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-dresses/marni-red-&-black-suit/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-dresses/marni-red-&-black-suit/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,62,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-181',62,62,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-181' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 182
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-jewellery'),'DUMMY-SPU-182','绿色水晶耳环','','','https://cdn.dummyjson.com/product-images/womens-jewellery/green-crystal-earring/thumbnail.webp','以鲜艳的绿色水晶为特色，璀璨夺目。经典设计为整体造型增添优雅气息，适合正式或特别场合。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-182');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-182','绿色水晶耳环',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-182');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-jewellery/green-crystal-earring/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-jewellery/green-crystal-earring/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,54,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-182',54,54,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-182' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 183
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-jewellery'),'DUMMY-SPU-183','绿色椭圆耳环','','','https://cdn.dummyjson.com/product-images/womens-jewellery/green-oval-earring/thumbnail.webp','造型独特的椭圆形设计，时尚百搭。无论休闲还是正式场合，绿色调与现代风格都能让它成为亮眼配饰。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-183');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-183','绿色椭圆耳环',JSON_OBJECT(),24.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-183');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-jewellery/green-oval-earring/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-jewellery/green-oval-earring/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,73,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-183',73,73,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-183' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 184
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-jewellery'),'DUMMY-SPU-184','热带风情耳环','','','https://cdn.dummyjson.com/product-images/womens-jewellery/tropical-earring/thumbnail.webp','灵感来自热带元素，趣味活泼的配饰。鲜艳色彩与生动设计，为造型增添一抹夏日气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-184');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-184','热带风情耳环',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-184');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-jewellery/tropical-earring/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-jewellery/tropical-earring/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-184',1,1,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-184' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 185
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-shoes'),'DUMMY-SPU-185','黑棕拼色拖鞋','','舒适潮流','https://cdn.dummyjson.com/product-images/womens-shoes/black-&-brown-slipper/thumbnail.webp','舒适时尚，适合日常休闲穿着。黑色与棕色的搭配，为放松时光增添一丝精致感。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-185');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-185','黑棕拼色拖鞋',JSON_OBJECT(),19.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-185');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-shoes/black-&-brown-slipper/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-shoes/black-&-brown-slipper/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,3,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-185',3,3,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-185' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 186
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-shoes'),'DUMMY-SPU-186','卡尔文·克莱因高跟鞋','','卡尔文·克莱因','https://cdn.dummyjson.com/product-images/womens-shoes/calvin-klein-heel-shoes/thumbnail.webp','优雅精致，专为正式场合设计。经典款式搭配优质材质，可为时尚造型锦上添花。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-186');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-186','卡尔文·克莱因高跟鞋',JSON_OBJECT(),79.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-186');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-shoes/calvin-klein-heel-shoes/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-shoes/calvin-klein-heel-shoes/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,93,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-186',93,93,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-186' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 187
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-shoes'),'DUMMY-SPU-187','女士金色鞋','','时尚女王','https://cdn.dummyjson.com/product-images/womens-shoes/golden-shoes-woman/thumbnail.webp','适合特别场合的华丽之选。金色外观搭配时尚设计，为穿搭增添奢华气息。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-187');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-187','女士金色鞋',JSON_OBJECT(),49.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-187');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-shoes/golden-shoes-woman/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-shoes/golden-shoes-woman/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-187',88,88,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-187' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 188
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-shoes'),'DUMMY-SPU-188','Pampi（潘皮） 鞋','','Pampi（潘皮）','https://cdn.dummyjson.com/product-images/womens-shoes/pampi-shoes/thumbnail.webp','兼顾舒适与时尚，适合日常穿着。百搭设计适用于多种休闲场合，打造潮流又轻松的造型。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-188');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-188','Pampi（潘皮） 鞋',JSON_OBJECT(),29.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-188');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-shoes/pampi-shoes/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-shoes/pampi-shoes/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,49,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-188',49,49,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-188' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 189
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-shoes'),'DUMMY-SPU-189','红色鞋子','','时尚快线','https://cdn.dummyjson.com/product-images/womens-shoes/red-shoes/thumbnail.webp','以鲜艳红色打造醒目造型。无论参加派对还是休闲外出，都能为衣橱增添亮色与风格。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-189');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-189','红色鞋子',JSON_OBJECT(),34.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-189');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-shoes/red-shoes/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-shoes/red-shoes/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-189',7,7,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-189' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 190
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-watches'),'DUMMY-SPU-190','万国表 Ingenieur 自动机械钢表','','万国表','https://cdn.dummyjson.com/product-images/womens-watches/iwc-ingenieur-automatic-steel/thumbnail.webp','耐用而精致的腕表，采用不锈钢表壳和自动机芯，为钟表爱好者兼顾精准性能与时尚风格。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-190');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-190','万国表 Ingenieur 自动机械钢表',JSON_OBJECT(),4999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-190');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-watches/iwc-ingenieur-automatic-steel/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-watches/iwc-ingenieur-automatic-steel/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-190',90,90,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-190' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 191
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-watches'),'DUMMY-SPU-191','劳力士 Cellini 月相腕表','','劳力士','https://cdn.dummyjson.com/product-images/womens-watches/rolex-cellini-moonphase/thumbnail.webp','制表工艺的杰作，配备月相复杂功能，展现劳力士享誉盛名的精湛工艺与优雅气质。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-191');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-191','劳力士 Cellini 月相腕表',JSON_OBJECT(),15999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-191');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-watches/rolex-cellini-moonphase/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-watches/rolex-cellini-moonphase/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,52,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-191',52,52,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-191' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 192
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-watches'),'DUMMY-SPU-192','劳力士 Datejust 女士腕表','','劳力士','https://cdn.dummyjson.com/product-images/womens-watches/rolex-datejust-women/thumbnail.webp','专为女性设计的经典腕表，采用隽永设计并具备日期显示功能，兼具优雅与实用。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-192');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-192','劳力士 Datejust 女士腕表',JSON_OBJECT(),10999.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-192');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-watches/rolex-datejust-women/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-watches/rolex-datejust-women/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,4,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-192',4,4,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-192' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 193
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-watches'),'DUMMY-SPU-193','女士金色腕表','','时尚金饰','https://cdn.dummyjson.com/product-images/womens-watches/watch-gold-for-women/thumbnail.webp','融合奢华与时尚的亮眼配饰，配有镀金表壳和别致设计，为任何穿搭增添迷人光彩。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-193');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-193','女士金色腕表',JSON_OBJECT(),799.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-193');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-watches/watch-gold-for-women/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-watches/watch-gold-for-women/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-193',0,0,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-193' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);

-- DummyJSON product 194
INSERT INTO gds_spu (category_id,spu_code,name,subtitle,brand_name,main_image,detail_content,status) VALUES ((SELECT id FROM gds_category WHERE category_code='DUMMY-CAT-womens-watches'),'DUMMY-SPU-194','女士腕表','','时尚公司','https://cdn.dummyjson.com/product-images/womens-watches/women''s-wrist-watch/thumbnail.webp','百搭时尚，适合日常佩戴。舒适表带搭配简约而优雅的设计，可与多种风格相衬。',1)
ON DUPLICATE KEY UPDATE name=VALUES(name),brand_name=VALUES(brand_name),main_image=VALUES(main_image),detail_content=VALUES(detail_content),status=1;
SET @spu_id=(SELECT id FROM gds_spu WHERE spu_code='DUMMY-SPU-194');
INSERT INTO gds_sku (spu_id,sku_code,name,spec_json,sale_price,market_price,weight_gram,status) VALUES (@spu_id,'DUMMY-SKU-194','女士腕表',JSON_OBJECT(),129.99,NULL,NULL,1)
ON DUPLICATE KEY UPDATE name=VALUES(name),sale_price=VALUES(sale_price),market_price=VALUES(market_price),status=1;
SET @sku_id=(SELECT id FROM gds_sku WHERE sku_code='DUMMY-SKU-194');
INSERT INTO gds_product_image (spu_id,sku_id,image_url,image_type,sort_order) SELECT @spu_id,@sku_id,'https://cdn.dummyjson.com/product-images/womens-watches/women''s-wrist-watch/thumbnail.webp',1,0 WHERE NOT EXISTS (SELECT 1 FROM gds_product_image WHERE spu_id=@spu_id AND image_url='https://cdn.dummyjson.com/product-images/womens-watches/women''s-wrist-watch/thumbnail.webp');
INSERT INTO wms_stock (warehouse_id,sku_id,total_quantity,reserved_quantity) SELECT @dummy_warehouse_id,@sku_id,12,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock WHERE warehouse_id=@dummy_warehouse_id AND sku_id=@sku_id);
INSERT INTO wms_stock_ledger (sku_id,warehouse_id,business_type,business_no,quantity_delta,total_after,reserved_after) SELECT @sku_id,@dummy_warehouse_id,5,'DUMMYJSON-INIT-194',12,12,0 WHERE NOT EXISTS (SELECT 1 FROM wms_stock_ledger WHERE business_type=5 AND business_no='DUMMYJSON-INIT-194' AND sku_id=@sku_id AND warehouse_id=@dummy_warehouse_id);
COMMIT;
