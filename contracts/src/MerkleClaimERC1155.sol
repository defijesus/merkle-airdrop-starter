// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// ============ Imports ============

import { ERC1155 } from "@solmate/tokens/ERC1155.sol"; // Solmate: ERC1155
import { MerkleProof } from "@openzeppelin/utils/cryptography/MerkleProof.sol"; // OZ: MerkleProof

/// @title MerkleClaimERC1155
/// @notice ERC1155 claimable by members of a merkle tree
/// @author defijesus.eth
contract MerkleClaimERC1155 is ERC1155 {

  /// ============ Immutable storage ============

  /// @notice ERC1155-claimee inclusion root
  bytes32 public immutable merkleRoot;

  /// ============ Mutable storage ============

  /// @notice Mapping of addresses who have claimed tokens
  mapping(address => bool) public hasClaimed;

  /// ============ Errors ============

  /// @notice Thrown if address has already claimed
  error AlreadyClaimed();
  /// @notice Thrown if address/amount are not part of Merkle tree
  error NotInMerkle();

  /// ============ Constructor ============

  /// @notice Creates a new MerkleClaimERC1155 contract
  /// @param _merkleRoot of claimees
  constructor(
    bytes32 _merkleRoot
  ) ERC1155() {
    merkleRoot = _merkleRoot; // Update root
  }

  /// ============ Events ============

  /// @notice Emitted after a successful token claim
  /// @param to recipient of claim
  /// @param amount of tokens claimed
  event Claim(address indexed to, uint256 amount);

  /// ============ Functions ============

  /// @notice Allows claiming tokens if address is part of merkle tree
  /// @param to address of claimee
  /// @param amount of tokens owed to claimee
  /// @param proof merkle proof to prove address and amount are in tree
  function claim(address to, uint256 amount, bytes32[] calldata proof) external {
    // Throw if address has already claimed tokens
    if (hasClaimed[to]) revert AlreadyClaimed();

    // Verify merkle proof, or revert if not in tree
    bytes32 leaf = keccak256(abi.encodePacked(to, amount));
    bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
    if (!isValidLeaf) revert NotInMerkle();

    // Set address to claimed
    hasClaimed[to] = true;

    // Mint tokens to address
    _mint(to, 0, amount, "");

    // Emit claim event
    emit Claim(to, amount);
  }

  /// @notice Returns the tokenURI
  /// @param id the tokenID used to return the uri
  /// @dev update this function to fit your own requirements
  function uri(uint256 id) public view override returns (string memory) {
    return "ipfs://QmY3wiHvppVDqTyafZ2Q16rw33aNNMzFyFfBwYUAT3ajbo";
  }
}