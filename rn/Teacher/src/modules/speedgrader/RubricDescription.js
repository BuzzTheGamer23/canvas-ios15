//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import React, { Component } from 'react'
import { View, StyleSheet, Text, ScrollView } from 'react-native'
import { connect } from 'react-redux'
import i18n from 'format-message'
import Navigator from '../../routing/Navigator'
import Screen from '../../routing/Screen'
import WebContainer from '../../common/components/WebContainer'

export class RubricDescription extends Component {

  dismiss = () => {
    this.props.navigator.dismiss()
  }

  renderLongDescription () {
    if (!this.props.description || this.props.description.length === 0) {
      return (
        <View style={styles.emptyState}>
          <Text style={styles.emptyStateText}>{i18n('There currently is no long description for this item.')}</Text>
        </View>
      )
    }
    return (
      <View style={styles.container}>
        <ScrollView bounces={false}>
          <WebContainer html={this.props.description} scrollEnabled={false} navigator={this.props.navigator}/>
        </ScrollView>
      </View>
    )
  }

  render () {
    const description = this.renderLongDescription()
    return (
      <Screen
        title={i18n('Long Description')}
        rightBarButtons={[{
          title: i18n('Done'),
          style: 'done',
          testID: 'rubric-description.done',
          action: this.dismiss,
        }]}>
        { description }
      </Screen>
    )
  }
}

const styles = StyleSheet.create({
  container: {
    paddingTop: 24,
    paddingHorizontal: 16,
  },
  emptyState: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 32,
  },
  emptyStateText: {
    color: '#2D3B45',
    fontSize: 16,
    lineHeight: 19,
    textAlign: 'center',
  },
})

export function mapStateToProps (state: AppState, ownProps: RubricDescriptionOwnProps): RubricDescriptionDataProps {
  let rubric = state.entities.assignments[ownProps.assignmentID].data.rubric
  if (!rubric) {
    return { description: '' }
  }

  return {
    description: rubric.find(r => r.id === ownProps.rubricID).long_description,
  }
}

const Connected = connect(mapStateToProps)(RubricDescription)
export default (Connected: any)

type RubricDescriptionOwnProps = {
  assignmentID: string,
  rubricID: string,
  navigator: Navigator,
}

type RubricDescriptionDataProps = {
  description: string,
}
