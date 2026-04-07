package com.shopping.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.shopping.entity.Category;
import com.shopping.mapper.CategoryMapper;
import com.shopping.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 商品分类服务实现类
 * 实现分类相关的业务逻辑
 * 
 * @author 陈洪伟
 */
@Service
public class CategoryServiceImpl implements CategoryService {

    @Autowired
    private CategoryMapper categoryMapper;

    /**
     * 查询所有分类（树形结构）
     * 
     * @return 分类树形列表
     */
    @Override
    public List<Category> getCategoryTree() {
        List<Category> allCategories = categoryMapper.selectList(null);
        Map<Long, List<Category>> categoryMap = allCategories.stream()
                .collect(Collectors.groupingBy(Category::getParentId));
        List<Category> rootCategories = categoryMap.getOrDefault(0L, new ArrayList<>());
        buildTree(rootCategories, categoryMap);
        return rootCategories;
    }

    /**
     * 根据父ID查询子分类
     * 
     * @param parentId 父分类ID
     * @return 子分类列表
     */
    @Override
    public List<Category> getChildrenByParentId(Long parentId) {
        LambdaQueryWrapper<Category> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Category::getParentId, parentId)
                .orderByAsc(Category::getSort);
        return categoryMapper.selectList(queryWrapper);
    }

    /**
     * 递归构建分类树
     * 
     * @param categories 当前层级的分类列表
     * @param categoryMap 分类映射表
     */
    private void buildTree(List<Category> categories, Map<Long, List<Category>> categoryMap) {
        if (categories == null || categories.isEmpty()) {
            return;
        }
        for (Category category : categories) {
            List<Category> children = categoryMap.getOrDefault(category.getId(), new ArrayList<>());
            category.setChildren(children);
            buildTree(children, categoryMap);
        }
    }

    @Override
    public Category saveCategory(Category category) {
        categoryMapper.insert(category);
        return category;
    }

    @Override
    public Category updateCategory(Category category) {
        categoryMapper.updateById(category);
        return category;
    }

    @Override
    public boolean deleteCategory(Long id) {
        // 检查是否有子分类
        LambdaQueryWrapper<Category> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Category::getParentId, id);
        long count = categoryMapper.selectCount(queryWrapper);
        if (count > 0) {
            throw new RuntimeException("该分类下存在子分类，无法删除");
        }
        categoryMapper.deleteById(id);
        return true;
    }

    @Override
    public List<Category> getCategoryList() {
        return categoryMapper.selectList(null);
    }

}
