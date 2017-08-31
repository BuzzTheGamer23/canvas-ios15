//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* @flow */

import 'react-native'
import React from 'react'
import renderer from 'react-test-renderer'

import ZSSRichTextEditor from '../ZSSRichTextEditor'
import explore from '../../../../../test/helpers/explore'
import setProps from '../../../../../test/helpers/setProps'

jest
  .mock('WebView', () => 'WebView')
  .mock('ScrollView', () => 'ScrollView')
  .mock('TouchableHighlight', () => 'TouchableHighlight')
  .mock('Button', () => 'Button')
  .mock('../LinkModal', () => 'LinkModal')

describe('ZSSRichTextEditor', () => {
  let js
  beforeEach(() => {
    js = jest.fn()
  })

  const options = {
    createNodeMock: (element) => {
      if (element.type === 'WebView') {
        return {
          injectJavaScript: js,
        }
      }
    },
  }

  const webView = (component) => {
    return explore(component.toJSON()).query(({ type }) => type === 'WebView')[0]
  }

  const linkModal = (component) => {
    return explore(component.toJSON()).query(({ type }) => type === 'LinkModal')[0]
  }

  it('renders', () => {
    expect(
      renderer.create(
        <ZSSRichTextEditor />
      )
    ).toMatchSnapshot()
  })

  it('provides unique active editor items', () => {
    const items = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor editorItemsChanged={items} />
    )
    const web = webView(component)
    postMessage(web, 'CALLBACK', ['link'])

    expect(items).toHaveBeenCalledWith(['link'])

    postMessage(web, 'CALLBACK', ['link'])
    expect(items).toHaveBeenCalledTimes(1)
  })

  it('sends input changes', () => {
    const input = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor onInputChange={input} />, options
    )

    const web = webView(component)
    postMessage(web, 'EDITOR_INPUT', '<p>sends input changes</p>')

    expect(input).toHaveBeenCalledWith('<p>sends input changes</p>')
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('notifies when editor focused', () => {
    const onFocus = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor onFocus={onFocus} />, options
    )

    const web = webView(component)
    postMessage(web, 'EDITOR_FOCUSED')

    expect(onFocus).toHaveBeenCalled()
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('responds when zss editor loads', () => {
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )

    const web = webView(component)
    postMessage(web, 'ZSS_LOADED')

    expect(js.mock.calls).toMatchSnapshot()
  })

  it('triggers undo', () => {
    testTrigger((editor) => editor.undo())
  })

  it('triggers redo', () => {
    testTrigger((editor) => editor.redo())
  })

  it('triggers bold', () => {
    testTrigger((editor) => editor.setBold())
  })

  it('triggers italic', () => {
    testTrigger((editor) => editor.setItalic())
  })

  it('triggers setPlaceholder', () => {
    testTrigger((editor) => editor.setPlaceholder('Add text'))
    testTrigger((editor) => editor.setPlaceholder(null))
  })

  it('shows link modal', () => {
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )
    component.getInstance().insertLink()
    const web = webView(component)
    postMessage(web, 'INSERT_LINK')
    expect(component.toJSON()).toMatchSnapshot()
  })

  it('shows link modal when link touched', () => {
    const link = {
      url: 'http://test-update-link.com',
      title: 'test update link',
    }
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )
    component.getInstance().insertLink()
    const web = webView(component)
    postMessage(web, 'LINK_TOUCHED', link)
    expect(component.toJSON()).toMatchSnapshot()
  })

  describe('link modal', () => {
    it('triggers insert new link', () => {
      const component = renderer.create(
        <ZSSRichTextEditor />, options
      )
      component.getInstance().insertLink()
      postMessage(webView(component), 'INSERT_LINK')
      linkModal(component).props.linkCreated('url', 'title')

      expect(js.mock.calls).toMatchSnapshot()
    })

    it('triggers insert link with selection', () => {
      const component = renderer.create(
        <ZSSRichTextEditor />, options
      )
      component.getInstance().insertLink()
      postMessage(webView(component), 'INSERT_LINK', 'selection')
      expect(component).toMatchSnapshot()
    })

    it('triggers update link', () => {
      const component = renderer.create(
        <ZSSRichTextEditor />, options
      )
      component.getInstance().insertLink()
      postMessage(webView(component), 'INSERT_LINK')
      linkModal(component).props.linkUpdated('url', 'title')

      expect(js.mock.calls).toMatchSnapshot()
    })
  })

  it('triggers text color', () => {
    testTrigger((editor) => editor.setTextColor('white'))
  })

  it('triggers unordered list', () => {
    testTrigger((editor) => editor.setUnorderedList())
  })

  it('triggers ordered list', () => {
    testTrigger((editor) => editor.setOrderedList())
  })

  it('triggers focus', () => {
    testTrigger((editor) => editor.focusEditor())
  })

  it('triggers blur', () => {
    testTrigger((editor) => editor.blurEditor())
  })

  it('sets custom css on web view loaded', () => {
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )
    const web = webView(component)
    web.props.onLoad()
    expect(js.mock.calls).toMatchSnapshot()
  })

  it('notifies when editor loaded', () => {
    const onLoad = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor onLoad={onLoad} />, options
    )
    const web = webView(component)
    expect(onLoad).not.toHaveBeenCalled()
    web.props.onLoad()
    expect(onLoad).toHaveBeenCalled()
  })

  it('notifies when editor blurred', () => {
    const onBlur = jest.fn()
    const component = renderer.create(
      <ZSSRichTextEditor onBlur={onBlur} />
    )
    const web = webView(component)
    postMessage(web, 'EDITOR_BLURRED')
    expect(onBlur).toHaveBeenCalled()
  })

  it('updates html if not provided initially', () => {
    const component = renderer.create(
      <ZSSRichTextEditor html={null} />, options
    )
    expect(js).not.toHaveBeenCalled()
    setProps(component, { html: 'here it is' })
    expect(js.mock.calls).toMatchSnapshot()
  })

  function testTrigger (trigger: (editor: any) => void): any {
    const component = renderer.create(
      <ZSSRichTextEditor />, options
    )
    trigger(component.getInstance())
    expect(js.mock.calls).toMatchSnapshot()
    return component
  }

  function postMessage (webView: any, type: string, data: any) {
    const message = { type: type, data: data }
    const event = { nativeEvent: { data: JSON.stringify(message) } }
    webView.props.onMessage(event)
  }
})
