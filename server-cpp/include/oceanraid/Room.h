#pragma once

#include <cstddef>
#include <string>
#include <unordered_set>

namespace oceanraid {

class Room {
public:
    Room(std::string room_id, std::string mode, std::size_t capacity);

    bool join(const std::string& player_id);
    bool leave(const std::string& player_id);
    bool contains(const std::string& player_id) const;
    std::size_t onlinePlayers() const noexcept;
    std::size_t capacity() const noexcept;
    const std::string& id() const noexcept;
    const std::string& mode() const noexcept;

private:
    std::string room_id_;
    std::string mode_;
    std::size_t capacity_;
    std::unordered_set<std::string> players_;
};

}  // namespace oceanraid
