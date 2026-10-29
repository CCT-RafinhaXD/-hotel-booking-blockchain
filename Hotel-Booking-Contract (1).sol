// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HotelBooking {
    address public hotelAddress;
    uint public roomPrice;
    uint public cancellationWindow;                    // v3: prazo em segundos
    mapping(address => bool) public hasPaid;
    mapping(address => bool) public hasCheckedIn;
    mapping(address => uint) public bookingTime;       // v3: horário da reserva

    constructor(uint _price, uint _cancellationWindow) {   // v3: novo parâmetro
        hotelAddress = msg.sender;
        roomPrice = _price;
        cancellationWindow = _cancellationWindow;          // v3
    }
    modifier onlyHotel() {
        require(msg.sender == hotelAddress, "Only the Hotel can do this");
        _;
    }
    function bookRoom() public payable {
        require(msg.value == roomPrice, "Payment must match the room price");
        require(!hasPaid[msg.sender], "Room already booked");
        hasPaid[msg.sender] = true;
        bookingTime[msg.sender] = block.timestamp;         // v3
    }

    function checkIn(address _guest) public onlyHotel {
        require(hasPaid[_guest], "Guest has not paid for the room");
        require(!hasCheckedIn[_guest], "Guest has already checked in");
        hasCheckedIn[_guest] = true;
        (bool success, ) = payable(hotelAddress).call{value: roomPrice}("");
        require(success, "Payment to hotel failed");
    }

    // v3: hóspede cancela dentro do prazo e recebe reembolso
    function cancelBooking() public {
        require(hasPaid[msg.sender], "No booking found for this address");
        require(!hasCheckedIn[msg.sender], "Cannot cancel after check-in");
        require(
            block.timestamp <= bookingTime[msg.sender] + cancellationWindow,
            "Cancellation period has expired"
        );

        // Checks-Effects-Interactions: zera o estado ANTES de enviar o ETH
        hasPaid[msg.sender] = false;
        bookingTime[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: roomPrice}("");
        require(success, "Refund failed");
    }

    // v3 (opcional): segundos restantes para cancelar, útil nos screenshots
    function timeLeftToCancel(address _guest) public view returns (uint) {
        if (!hasPaid[_guest] || hasCheckedIn[_guest]) return 0;
        uint deadline = bookingTime[_guest] + cancellationWindow;
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
