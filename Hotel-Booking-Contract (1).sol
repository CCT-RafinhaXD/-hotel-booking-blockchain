// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HotelBooking {
    address public hotelAddress;
    uint public roomPrice;
    mapping(address => bool) public hasPaid;
    mapping(address => bool) public hasCheckedIn;

    constructor(uint _price) {
        hotelAddress = msg.sender;
        roomPrice = _price;
    }
    modifier onlyHotel() {
        require(msg.sender == hotelAddress, "Only the Hotel can do this");
        _;
    }
    function bookRoom() public payable {
        require(msg.value == roomPrice, "Payment must match the room price");
        require(!hasPaid[msg.sender], "Room already booked");
        hasPaid[msg.sender] = true;
    }

    function checkIn(address _guest) public onlyHotel {
        require(hasPaid[_guest], "Guest has not paid for the room");
        require(!hasCheckedIn[_guest], "Guest has already checked in");
        hasCheckedIn[_guest] = true;
        (bool success, ) = payable(hotelAddress).call{value: roomPrice}("");
        require(success, "Payment to hotel failed");
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
