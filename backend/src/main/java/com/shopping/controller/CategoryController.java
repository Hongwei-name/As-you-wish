package com.shopping.controller;

import com.shopping.common.Result;
import com.shopping.entity.Category;
import com.shopping.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 商品分类控制器
 * 提供分类相关的接口
 * 
 * @author 陈洪伟
 */
@RestController
@RequestMapping("/api/category")
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    /**
     * 获取所有分类（树形结构）
     * 
     * @return 分类树形列表
     */
    @GetMapping("/list")
    public Result<List<Category>> getCategoryTree() {
        List<Category> categoryTree = categoryService.getCategoryTree();
        return Result.success(categoryTree);
    }

    /**
     * 获取子分类
     * 
     * @param parentId 父分类ID
     * @return 子分类列表
     */
    @GetMapping("/children/{parentId}")
    public Result<List<Category>> getChildren(@PathVariable Long parentId) {
        List<Category> children = categoryService.getChildrenByParentId(parentId);
        return Result.success(children);
    }

}
