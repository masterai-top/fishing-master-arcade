#include "oceanraid/FishingEngine.h"
#include "oceanraid/Room.h"

#include <iostream>

int main() {
    oceanraid::Room room("classic-rookie-01", "classic", 100);
    room.join("local-player");

    // Fixed seed is for a reproducible development smoke test only.
    oceanraid::FishingEngine engine(42);
    const oceanraid::FishSpec fish{"small-fish", "Small Fish", 2, 0.5};
    const auto result = engine.resolveShot(1'000, 10, fish);

    std::cout << "room=" << room.id() << " players=" << room.onlinePlayers()
              << " captured=" << result.captured << " balance=" << result.balance_after
              << '\n';
    return 0;
}
