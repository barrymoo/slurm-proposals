{-# LANGUAGE DeriveAnyClass    #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE OverloadedStrings #-}

module Database where

import           Database.Beam
import           Database.SQLite.Simple

import           Table.Account
import           Table.Proposal
import           Table.PurchasedUnit
import           Table.Statistic

data ProposalsDb f =
  ProposalsDb
    { _proposalsAccount        :: f (TableEntity AccountT)
    , _proposalsProposals      :: f (TableEntity ProposalT)
    , _proposalsPurchasedUnits :: f (TableEntity PurchasedUnitT)
    , _proposalsStatistics     :: f (TableEntity StatisticT)
    }
  deriving (Generic, Database be)

proposalsDb :: DatabaseSettings be ProposalsDb
proposalsDb =
  defaultDbSettings `withDbModification`
  dbModification
    { _proposalsAccount =
        setEntityName "accounts" <>
        modifyTableFields
          tableModification
            {_accountId = "id", _accountName = "name", _accountOwner = "owner"}
    , _proposalsProposals =
        setEntityName "proposals" <>
        modifyTableFields
          tableModification
            { _proposalId = "id"
            , _proposalServiceUnits = "service_units"
            , _proposalExpirationDate = "expiration_date"
            , _proposalNotificationPercent = "notification_percent"
            , _proposalLocked = "locked"
            , _proposalAccount = AccountId "account__id"
            }
    , _proposalsPurchasedUnits =
        setEntityName "purchased_units" <>
        modifyTableFields
          tableModification
            { _purchasedUnitId = "id"
            , _purchasedUnitUnits = "service_units"
            , _purchasedUnitExpirationDate = "expiration_date"
            , _purchasedUnitAccount = AccountId "account__id"
            }
    , _proposalsStatistics =
        setEntityName "statistics" <>
        modifyTableFields
          tableModification
            { _statisticId = "id"
            , _statisticUnusedUnits = "unused_service_units"
            , _statisticAccount = AccountId "account__id"
            }
    }
-- FIXME: Instead of using Beam migrations, just create the tables and db
