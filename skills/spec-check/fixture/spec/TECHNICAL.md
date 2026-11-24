# pantry: technical specification

How pantry realises `FUNCTIONAL.md`.

## 1. Constraints

Realises: – (V2: the list stays on the phones)

pantry is a phone app for two phone platforms. Each phone keeps the list in a local database.

## 2. Sync

Realises: F-SHARE-1, F-SHARE-2, F-SHARE-4, F-QUAL-1

Phones of one household find each other on the local network and through a relay that forwards
encrypted messages and keeps nothing. A phone collects its changes and sends them every five
minutes. The relay is a phone of every household it serves, so changes reach it like any other
phone. A joining phone receives the whole list from the first phone that answers.

## 3. Adding

Realises: F-ADD-*

Item names are compared without case. The add button keeps a count per item name on the phone.

## 4. Security

Realises: – (VB1)

The relay sees only encrypted messages. A household key, made on the first phone, encrypts every
message; a phone gets it when it joins.

## Not designed yet

- F-SHARE-3: not designed yet; the slice that builds offline restore designs it.
