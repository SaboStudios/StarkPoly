use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    player: ContractAddress, // Unique player identifier (wallet address)
    balance: u128, // Player's money balance
    position: u8, // Position on the board (0-39 for a standard Monopoly board)
    in_jail: bool, // Whether the player is in jail
    jail_turns: u8, // Number of turns in jail
    // properties_owned: Vec<u8>,  List of property IDs owned by the player
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Property {
    #[key]
    property_id: u8, // Unique property identifier (0-39 for standard Monopoly)
    owner: Option<ContractAddress>, // Owner of the property
    price: u128, // Price of the property
    rent: u128, // Rent amount
    houses: u8, // Number of houses built
    mortgaged: bool, // Whether the property is mortgaged
}

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    game_id: u32, // Unique game identifier
    players: Vec<ContractAddress>, // List of players in the game
    current_turn: u8, // Current player's turn index
    started: bool, // Whether the game has started
    ended: bool, // Whether the game has ended
    winner: Option<ContractAddress>, // Winner of the game
}
//  na here i stop
#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Move {
    #[key]
    player: ContractAddress, // Player making the move
    dice_roll: (u8, u8), // Dice roll result (two dice)
    new_position: u8, // New position after move
    passed_go: bool, // Whether the player passed GO
}


#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Moves {
    #[key]
    pub player: ContractAddress,
    pub remaining: u8,
    pub last_direction: Option<Direction>,
    pub can_move: bool,
}

#[derive(Drop, Serde, Debug)]
#[dojo::model]
pub struct DirectionsAvailable {
    #[key]
    pub player: ContractAddress,
    pub directions: Array<Direction>,
}

#[derive(Copy, Drop, Serde, Debug)]
#[dojo::model]
pub struct Position {
    #[key]
    pub player: ContractAddress,
    pub vec: Vec2,
}


#[derive(Serde, Copy, Drop, Introspect, PartialEq, Debug)]
pub enum Direction {
    Left,
    Right,
    Up,
    Down,
}


#[derive(Copy, Drop, Serde, IntrospectPacked, Debug)]
pub struct Vec2 {
    pub x: u32,
    pub y: u32,
}


impl DirectionIntoFelt252 of Into<Direction, felt252> {
    fn into(self: Direction) -> felt252 {
        match self {
            Direction::Left => 1,
            Direction::Right => 2,
            Direction::Up => 3,
            Direction::Down => 4,
        }
    }
}

impl OptionDirectionIntoFelt252 of Into<Option<Direction>, felt252> {
    fn into(self: Option<Direction>) -> felt252 {
        match self {
            Option::None => 0,
            Option::Some(d) => d.into(),
        }
    }
}

#[generate_trait]
impl Vec2Impl of Vec2Trait {
    fn is_zero(self: Vec2) -> bool {
        if self.x - self.y == 0 {
            return true;
        }
        false
    }

    fn is_equal(self: Vec2, b: Vec2) -> bool {
        self.x == b.x && self.y == b.y
    }
}

#[cfg(test)]
mod tests {
    use super::{Vec2, Vec2Trait};

    #[test]
    fn test_vec_is_zero() {
        assert(Vec2Trait::is_zero(Vec2 { x: 0, y: 0 }), 'not zero');
    }

    #[test]
    fn test_vec_is_equal() {
        let position = Vec2 { x: 420, y: 0 };
        assert(position.is_equal(Vec2 { x: 420, y: 0 }), 'not equal');
    }
}
