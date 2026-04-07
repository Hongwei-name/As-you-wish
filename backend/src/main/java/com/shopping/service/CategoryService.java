package com.shopping.service;

import com.shopping.entity.Category;

import java.util.List;

/**
 * 商品分类服务接口
 * 提供分类相关的业务逻辑
 * 
 * @author 陈洪伟
 */
public interface CategoryService {

    /**
     * 查询所有分类（树形结构）
     * 
     * @return 分类树形列表
     */
    List<Category> getCategoryTree();

    /**
     * 根据父ID查询子分类
     * 
     * @param parentId 父分类ID
     * @return 子分类列表
     */
    List<Category> getChildrenByParentId(Long parentId);

    /**
     * 保存分类
     * 
     * @param category 分类信息
     * @return 保存后的分类
     */
    Category saveCategory(Category category);

    /**
     * 更新分类
     * 
     * @param category 分类信息
     * @return 更新后的分类
     */
    Category updateCategory(Category category);

    /**
     * 删除分类
     * 
     * @param id 分类ID
     * @return 是否成功
     */
    boolean deleteCategory(Long id);

    /**
     * 获取分类列表（管理端）
     * 
     * @return 分类列表
     */
    List<Category> getCategoryList();

}
