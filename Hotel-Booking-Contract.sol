// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HotelBooking {
address public hotelAddress;
uint public roomPrice;
mapping (address => bool) public hasPaid;

constructor (uint _price) {
  hotelAddress = msg.sender;
  roomPrice = _price;
}
function bookRoom() public payable {
  require(msg.value == roomPrice, "that the payment must match the room price");
  require(!hasPaid [msg.sender], "Room already booked");
  hasPaid[msg.sender] = true;
}

function getBalance() public view returns (uint){
  return address(this).balance;
}
  }
