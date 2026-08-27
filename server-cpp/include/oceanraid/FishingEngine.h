#pragma once

#include <cstdint>
#include <random>
#include <string>

namespace oceanraid {

struct FishSpec {
    std::string fish_id;
    std::string display_name;
    std::uint32_t reward_multiplier;
    double capture_probability;
};

struct ShotResult {
    bool captured;
    std::uint64_t reward;
    std::uint64_t balance_after;
};

class FishingEngine {
public:
    explicit FishingEngine(std::uint32_t development_seed);

    ShotResult resolveShot(
        std::uint64_t balance,
        std::uint64_t cannon_cost,
        const FishSpec& fish);

private:
    std::mt19937 random_;
    std::uniform_real_distribution<double> distribution_{0.0, 1.0};
};

}  // namespace oceanraid
