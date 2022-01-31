// SPDX-License-Identifier: Apache 2

pragma solidity ^0.7.6;
pragma abicoder v2;

import './IWormhole.sol';
import 'solidity-bytes-utils/contracts/BytesLib.sol';


/// @title Helper library for cross-chain swaps
/// @notice Contains functions necessary for parsing encoded VAAs
/// and structs containing swap parameters
library SwapHelper {
    using BytesLib for bytes;

    /// @dev Parameters needed for exactIn swap type
    struct ExactInParameters {
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint256 targetAmountOutMinimum;
        bytes32 targetChainRecipient;
        uint256 deadline;
        uint24 poolFee;
    }

    /// @dev Parameters needed for exactOut swap type
    struct ExactOutParameters {
        uint256 amountOut;
        uint256 amountInMaximum;
        uint256 targetAmountOut;
        bytes32 targetChainRecipient;
        uint256 deadline;
        uint24 poolFee;
    }

    /// @dev Parameters parsed from a VAA for executing swaps
    /// on the destination chain
    struct DecodedVaaParameters {
        // in order of decoding
        uint8 version;
        uint256 swapAmount;
        address contractAddress;
        uint256 relayerFee;
        uint256 estimatedAmount;
        address recipientAddress;
        address[2] path;
        uint256 deadline;
        uint24 poolFee;
        uint8 swapFunctionType;
        uint8 swapCurrencyType;
    }

    /// @dev Decodes parameters encoded in a VAA
    function decodeVaaPayload(
        IWormhole.VM memory encodedVm
    ) public view returns (DecodedVaaParameters memory decoded) {
        uint index = 0;

        decoded.version = encodedVm.payload.toUint8(index);
        index += 1;

        decoded.swapAmount = encodedVm.payload.toUint256(index);
        index += 32;

        // skip
        index += 46;

        decoded.contractAddress = encodedVm.payload.toAddress(index);
        index += 20;

        // skip
        index += 2;

        decoded.relayerFee = encodedVm.payload.toUint256(index);
        index += 32;

        decoded.estimatedAmount = encodedVm.payload.toUint256(index);
        index += 44;

        decoded.recipientAddress = encodedVm.payload.toAddress(index);
        index += 20;

        decoded.path[0] = encodedVm.payload.toAddress(index);
        index += 20;

        decoded.path[1] = encodedVm.payload.toAddress(index);
        index += 20;

        decoded.deadline = encodedVm.payload.toUint256(index);
        index += 32;

        // skip
        index += 1;

        decoded.poolFee = encodedVm.payload.toUint16(index);
        index += 2;

        decoded.swapFunctionType = encodedVm.payload.toUint8(index);
        index += 1;

        decoded.swapCurrencyType = encodedVm.payload.toUint8(index);
    }
}