#include "oceanraid/FishingEngine.h"

#include <limits>
#include <stdexcept>

namespace oceanraid {

FishingEngine::FishingEngine(std::uint32_t development_seed) : random_(development_seed) {}

ShotResult FishingEngine::resolveShot(
    std::uint64_t balance,
    std::uint64_t cannon_cost,
    const FishSpec& fish) {
    if (cannon_cost == 0 || cannon_cost > balance) {
        throw std::invalid_argument("cannon cost must be positive and within balance");
    }
    if (fish.reward_multiplier == 0 || fish.capture_probability < 0.0 ||
        fish.capture_probability > 1.0) {
        throw std::invalid_argument("invalid fish specification");
    }
    if (cannon_cost > std::numeric_limits<std::uint64_t>::max() / fish.reward_multiplier) {
        throw std::overflow_error("reward exceeds uint64 range");
    }

    const bool captured = distribution_(random_) < fish.capture_probability;
    const std::uint64_t reward = captured ? cannon_cost * fish.reward_multiplier : 0;
    return ShotResult{captured, reward, balance - cannon_cost + reward};
}

}  // namespace oceanraid
