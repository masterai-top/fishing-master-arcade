#include "oceanraid/Room.h"

#include <stdexcept>
#include <utility>

namespace oceanraid {

Room::Room(std::string room_id, std::string mode, std::size_t capacity)
    : room_id_(std::move(room_id)), mode_(std::move(mode)), capacity_(capacity) {
    if (room_id_.empty() || mode_.empty() || capacity_ == 0) {
        throw std::invalid_argument("room id, mode and capacity are required");
    }
}

bool Room::join(const std::string& player_id) {
    if (player_id.empty() || players_.size() >= capacity_) {
        return false;
    }
    return players_.insert(player_id).second;
}

bool Room::leave(const std::string& player_id) {
    return players_.erase(player_id) == 1;
}

bool Room::contains(const std::string& player_id) const {
    return players_.find(player_id) != players_.end();
}

std::size_t Room::onlinePlayers() const noexcept { return players_.size(); }
std::size_t Room::capacity() const noexcept { return capacity_; }
const std::string& Room::id() const noexcept { return room_id_; }
const std::string& Room::mode() const noexcept { return mode_; }

}  // namespace oceanraid
