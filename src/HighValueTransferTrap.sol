// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IResponse {
    function handleHighValueTransfer(address token, address from, address to, uint256 amount, uint256 timestamp) external;
}

/// @title HighValueTransferTrap
/// @notice Stores configuration for a monitored token and exposes an admin-settable threshold.
///         Drosera off-chain node can call `notifyTransfer` (or the response directly) when it detects a large transfer.
contract HighValueTransferTrap is Ownable {
    // token => threshold (in token smallest units)
    mapping(address => uint256) public thresholds;

    // optional response contract (will be called on incident)
    IResponse public response;

    // recorded incident struct
    struct Incident {
        address token;
        address from;
        address to;
        uint256 amount;
        uint256 timestamp;
    }

    Incident[] public incidents;

    event ThresholdSet(address indexed token, uint256 threshold);
    event ResponseSet(address indexed response);
    event IncidentRecorded(uint256 indexed incidentId, address indexed token, address from, address to, uint256 amount);

    constructor(address _response) {
        response = IResponse(_response);
    }

    /// @notice set monitoring threshold for a token (owner only)
    function setThreshold(address token, uint256 threshold) external onlyOwner {
        thresholds[token] = threshold;
        emit ThresholdSet(token, threshold);
    }

    /// @notice update the response contract address (owner only)
    function setResponse(address _response) external onlyOwner {
        response = IResponse(_response);
        emit ResponseSet(_response);
    }

    /// @notice Called by the Drosera node when a high-value transfer is detected off-chain.
    ///         You may also restrict this to only certain callers (operators) if desired.
    function notifyTransfer(address token, address from, address to, uint256 amount) external {
        uint256 thr = thresholds[token];
        require(thr != 0, "token not monitored");
        require(amount >= thr, "below threshold");

        uint256 ts = block.timestamp;
        incidents.push(Incident({ token: token, from: from, to: to, amount: amount, timestamp: ts }));
        uint256 id = incidents.length - 1;

        // call the response contract for further handling (non-reverting best-effort)
        try response.handleHighValueTransfer(token, from, to, amount, ts) {
            // success
        } catch {
            // swallow, still record incident locally
        }

        emit IncidentRecorded(id, token, from, to, amount);
    }

    /// @notice convenience view to get total incidents count
    function incidentsCount() external view returns (uint256) {
        return incidents.length;
    }
}
