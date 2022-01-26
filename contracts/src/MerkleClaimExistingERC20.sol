// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol";
import { Ownable } from "./Ownable.sol";
import { SafeTransferLib } from "@solmate/utils/SafeTransferLib.sol";

contract ClaimGroupiesAirdrop is Ownable {

  using SafeTransferLib for ERC20;

  ERC20 public immutable peaceToken;
  bytes32[] public merkleRoots;
  mapping(uint256 => bool) public isOpen;

  mapping(uint256 => mapping (address => bool)) public hasClaimed;

  error AlreadyClaimed();
  error NotInMerkle();
  error NotOpen();

  constructor(
    ERC20 _peaceToken
  ) {
    peaceToken = _peaceToken;
    _transferOwnership(msg.sender);
  }

  event Claim(address indexed to, uint256 amount);
  event NewRoot(bytes32 merkleRoot, uint256 index);

  function withdrawPeace (address to) external onlyOwner {
    peaceToken.safeTransfer(to, peaceToken.balanceOf(address(this)));
  }

  function addAirdrop (bytes32 _root, bool _open) external onlyOwner {
    merkleRoots.push(_root);
    isOpen[merkleRoots.length - 1] = _open;
    emit NewRoot(_root, merkleRoots.length - 1);
  }

  function setOpen (uint256 index, bool _open) external onlyOwner {
    isOpen[index] = _open;
  }

  function claim(uint256 index, address to, uint256 amount, bytes32[] calldata proof) external {
    if (!isOpen[index]) revert NotOpen();
    // Throw if address has already claimed tokens
    if (hasClaimed[index][to]) revert AlreadyClaimed();

    // Verify merkle proof, or revert if not in tree
    bytes32 leaf = keccak256(abi.encodePacked(to, amount));
    bool isValidLeaf = MerkleProof.verify(proof, merkleRoots[index], leaf);
    if (!isValidLeaf) revert NotInMerkle();

    // Set address to claimed
    hasClaimed[index][to] = true;

    // Send tokens to address
    peaceToken.safeTransfer(to, amount);

    // Emit claim event
    emit Claim(to, amount);
  }
}