#!/usr/bin/env python3

"""
Chilean RUT (Rol Unico Tributario) helper routines.

Compute the verification digit (digito verificador) from a bare numeric
body and format the full RUT with dots and dash (e.g. 23712470 -> 23.712.470-7).

Import from this module in any http-async-rotate requester that sweeps
over incremental RUT bodies.

"""


def rut_dv(body: int) -> str:
    """Compute the RUT verification digit for a numeric body via modulo 11.

    Algorithm:
      1. Multiply each digit from RIGHT to LEFT by weights cycling 2..7.
      2. Sum all products.
      3. remainder = 11 - (sum % 11).
      4. If remainder == 11 -> '0'; if 10 -> 'K'; else str(remainder).
    """
    total = 0
    weight = 2
    remaining = body
    while remaining > 0:
        total += (remaining % 10) * weight
        remaining //= 10
        weight = weight + 1 if weight < 7 else 2
    remainder = 11 - (total % 11)
    if remainder == 11:
        return "0"
    if remainder == 10:
        return "K"
    return str(remainder)


def rut_format(body: int) -> str:
    """Format a RUT body into the canonical dotted form with DV.

    Example: 15487632 -> '15.487.632-4'
    """
    dv = rut_dv(body)
    body_str = str(body)
    # Insert dots from right every 3 digits
    parts = []
    while len(body_str) > 3:
        parts.append(body_str[-3:])
        body_str = body_str[:-3]
    parts.append(body_str)
    dotted = ".".join(reversed(parts))
    return f"{dotted}-{dv}"


def rut_plain(body: int) -> str:
    """Return body-DV without dots (e.g. 15487632 -> '15487632-4')."""
    return f"{body}-{rut_dv(body)}"
