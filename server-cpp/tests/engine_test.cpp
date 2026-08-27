#include "oceanraid/FishingEngine.h"
#include "oceanraid/Room.h"

#include <cassert>
#include <stdexcept>

int main() {
    oceanraid::Room room("test-room", "classic", 1);
    assert(room.join("player-a"));
    assert(!room.join("player-b"));
    assert(room.contains("player-a"));
    assert(room.leave("player-a"));

    oceanraid::FishingEngine engine(7);
    const oceanraid::FishSpec guaranteed{"test-fish", "Test Fish", 5, 1.0};
    const auto result = engine.resolveShot(1'000, 10, guaranteed);
    assert(result.captured);
    assert(result.reward == 50);
    assert(result.balance_after == 1'040);

    bool rejected = false;
    try {
        engine.resolveShot(5, 10, guaranteed);
    } catch (const std::invalid_argument&) {
        rejected = true;
    }
    assert(rejected);
    return 0;
}
