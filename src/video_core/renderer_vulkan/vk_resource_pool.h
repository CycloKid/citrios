// SPDX-FileCopyrightText: Copyright 2020 yuzu Emulator Project
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include <vector>
#include "common/common_types.h"
#include "video_core/renderer_vulkan/vk_common.h"

namespace Vulkan {

class Instance;
class MasterSemaphore;

/**
 * Handles a pool of resources protected by fences. Manages resource overflow allocating more
 * resources.
 */
class ResourcePool {
public:
    explicit ResourcePool() = default;
    explicit ResourcePool(MasterSemaphore& master_semaphore, std::size_t grow_step);
    virtual ~ResourcePool() = default;

    ResourcePool& operator=(ResourcePool&&) noexcept = default;
    ResourcePool(ResourcePool&&) noexcept = default;

    ResourcePool& operator=(const ResourcePool&) = default;
    ResourcePool(const ResourcePool&) = default;

protected:
    std::size_t CommitResource();

    /// Called when a chunk of resources have to be allocated.
    virtual void Allocate(std::size_t begin, std::size_t end) = 0;

private:
    /// Manages pool overflow allocating new resources.
    std::size_t ManageOverflow();

    /// Allocates a new page of resources.
    void Grow();

protected:
    MasterSemaphore* master_semaphore{nullptr};
    std::size_t grow_step = 0;     ///< Number of new resources created after an overflow
    std::size_t hint_iterator = 0; ///< Hint to where the next free resources is likely to be found
    std::vector<u64> ticks;        ///< Ticks for each resource
};

class CommandPool final : public ResourcePool {
public:
    explicit CommandPool(const Instance& instance, MasterSemaphore& master_semaphore);
    ~CommandPool() override;

    void Allocate(std::size_t begin, std::size_t end) override;

    vk::CommandBuffer Commit();

private:
    struct Pool;
    const Instance& instance;
    std::vector<Pool> pools;
};

class DescriptorPool final : public ResourcePool {
public:
    explicit DescriptorPool(const Instance& instance, MasterSemaphore& master_semaphore);
    ~DescriptorPool() override;

    /// Refreshes the tick of the currently commited pool
    void RefreshTick();

    void Allocate(std::size_t begin, std::size_t end) override;

    vk::DescriptorPool Commit();

private:
    const Instance& instance;
    std::vector<vk::DescriptorPool> pools;
    std::size_t pool_index;
};

} // namespace Vulkan
